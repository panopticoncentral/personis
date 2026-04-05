import Foundation
import SwiftData
import SwiftUI

@Observable
final class ChatSessionViewModel {
    var currentChat: Chat?
    var streamingContent: String = ""
    var isGenerating: Bool = false
    var error: String?

    private let openRouter = OpenRouterService.shared
    private var generationTask: Task<Void, Never>?

    var displayMessages: [Message] {
        currentChat?.orderedMessages.filter { $0.role != .system } ?? []
    }

    @MainActor
    func startNewChat(
        character: Character,
        modelContext: ModelContext
    ) async {
        let chat = Chat(
            title: "New Chat",
            character: character,
            modelIdSnapshot: character.selectedModelId
        )
        modelContext.insert(chat)

        let systemMessage = Message(
            content: character.systemPrompt,
            role: .system,
            orderIndex: 0,
            chat: chat
        )
        modelContext.insert(systemMessage)

        // Add opening line as first assistant message if character has one
        let trimmedOpeningLine = character.openingLine.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedOpeningLine.isEmpty {
            let openingMessage = Message(
                content: trimmedOpeningLine,
                role: .assistant,
                orderIndex: 1,
                chat: chat
            )
            modelContext.insert(openingMessage)
        }

        save(modelContext)

        currentChat = chat
    }

    @MainActor
    func sendMessage(_ content: String, modelContext: ModelContext) async {
        guard let chat = currentChat else { return }

        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }

        // Update chat title from first user message if needed
        if chat.title == "New Chat" {
            chat.title = generateTitle(from: trimmedContent)
        }

        let nextIndex = (chat.orderedMessages.last?.orderIndex ?? 0) + 1
        let userMessage = Message(
            content: trimmedContent,
            role: .user,
            orderIndex: nextIndex,
            chat: chat
        )
        modelContext.insert(userMessage)
        chat.updatedAt = Date()

        save(modelContext)

        startGenerating(modelContext: modelContext)
    }

    @MainActor
    func regenerateLastResponse(modelContext: ModelContext) async {
        guard let chat = currentChat,
              let lastMessage = chat.orderedMessages.last,
              lastMessage.role == .assistant else { return }

        modelContext.delete(lastMessage)
        chat.updatedAt = Date()
        save(modelContext)

        startGenerating(modelContext: modelContext)
    }

    @MainActor
    func cancelGeneration() {
        generationTask?.cancel()
        generationTask = nil
        isGenerating = false
        streamingContent = ""
    }

    @MainActor
    private func startGenerating(modelContext: ModelContext) {
        generationTask?.cancel()
        generationTask = Task { @MainActor in
            await generateResponse(modelContext: modelContext)
        }
    }

    @MainActor
    private func generateResponse(modelContext: ModelContext) async {
        guard let chat = currentChat else { return }

        isGenerating = true
        error = nil
        streamingContent = ""

        let messages = chat.orderedMessages.map { message in
            ChatMessage(role: message.role.rawValue, content: message.content)
        }

        do {
            let stream = await openRouter.streamChatCompletion(
                model: chat.modelIdSnapshot,
                messages: messages,
                temperature: 0.8
            )

            var fullContent = ""

            for try await chunk in stream {
                try Task.checkCancellation()
                fullContent += chunk
                streamingContent = fullContent
            }

            guard !Task.isCancelled else { return }

            let nextIndex = (chat.orderedMessages.last?.orderIndex ?? 0) + 1
            let assistantMessage = Message(
                content: fullContent,
                role: .assistant,
                orderIndex: nextIndex,
                chat: chat
            )
            modelContext.insert(assistantMessage)
            chat.updatedAt = Date()

            save(modelContext)

            streamingContent = ""

        } catch is CancellationError {
            // Cancelled by user — not an error
        } catch {
            self.error = error.localizedDescription
        }

        isGenerating = false
    }

    func loadExistingChat(_ chat: Chat) {
        currentChat = chat
    }

    private func generateTitle(from content: String) -> String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if let periodIndex = trimmed.firstIndex(of: "."),
           trimmed.distance(from: trimmed.startIndex, to: periodIndex) < 60 {
            return String(trimmed[...periodIndex])
        }
        if trimmed.count <= 50 {
            return trimmed
        }
        let truncated = String(trimmed.prefix(47))
        return truncated + "..."
    }

    func deleteChat(_ chat: Chat, modelContext: ModelContext) {
        if currentChat?.id == chat.id {
            currentChat = nil
        }
        modelContext.delete(chat)
        save(modelContext)
    }

    private func save(_ modelContext: ModelContext) {
        do {
            try modelContext.save()
        } catch {
            self.error = "Failed to save: \(error.localizedDescription)"
        }
    }
}
