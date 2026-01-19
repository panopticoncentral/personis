import SwiftUI
import SwiftData

struct CharacterDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(CharacterListViewModel.self) private var viewModel

    let character: Character

    @State private var selectedChat: Chat?
    @State private var showingNewChat = false
    @State private var showingEditor = false
    @State private var showingDeleteConfirmation = false

    private var sortedChats: [Chat] {
        (character.chats ?? []).sorted { $0.updatedAt > $1.updatedAt }
    }

    var body: some View {
        List {
            Section {
                Button {
                    showingNewChat = true
                } label: {
                    Label("New Chat", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
            }

            if !sortedChats.isEmpty {
                Section("Conversations") {
                    ForEach(sortedChats) { chat in
                        Button {
                            selectedChat = chat
                        } label: {
                            ChatRowView(chat: chat)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteChats)
                }
            }
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditor = true
                    } label: {
                        Label("Edit Character", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Character", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            CharacterEditorView(character: character)
        }
        .confirmationDialog(
            "Delete Character",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteCharacter(character, modelContext: modelContext)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \"\(character.name)\"? This will also delete all chats.")
        }
        .navigationDestination(item: $selectedChat) { chat in
            ChatView(chat: chat)
        }
        .navigationDestination(isPresented: $showingNewChat) {
            NewChatView(character: character)
        }
        .overlay {
            if sortedChats.isEmpty {
                ContentUnavailableView(
                    "No Chats Yet",
                    systemImage: "bubble.left.and.bubble.right",
                    description: Text("Tap \"New Chat\" to start a conversation with \(character.name)")
                )
                .offset(y: 60)
            }
        }
    }

    private func deleteChats(at offsets: IndexSet) {
        let chatsToDelete = offsets.map { sortedChats[$0] }
        for chat in chatsToDelete {
            modelContext.delete(chat)
        }
    }
}

struct ChatRowView: View {
    let chat: Chat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(chat.title.isEmpty ? "New Chat" : chat.title)
                .font(.headline)
                .lineLimit(1)

            if let firstMessage = chat.orderedMessages.first(where: { $0.role == .assistant }) {
                Text(firstMessage.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Text(chat.updatedAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        CharacterDetailView(character: Character(
            name: "Sherlock Holmes",
            systemPrompt: "You are Sherlock Holmes...",
            selectedModelId: "anthropic/claude-sonnet-4"
        ))
    }
    .environment(CharacterListViewModel())
    .modelContainer(for: [Character.self, Chat.self, Message.self], inMemory: true)
}
