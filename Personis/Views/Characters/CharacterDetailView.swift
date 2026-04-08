import SwiftUI
import SwiftData

struct CharacterDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(CharacterListViewModel.self) private var viewModel

    let character: Character

    @State private var selectedChat: Chat?
    @State private var showingEditor = false
    @State private var showingDeleteConfirmation = false
    @State private var chatViewModel = ChatSessionViewModel()

    private var sortedChats: [Chat] {
        (character.chats ?? []).sorted { $0.updatedAt > $1.updatedAt }
    }

    var body: some View {
        List {
            // Profile header
            Section {
                VStack(spacing: 12) {
                    AvatarView(character: character, size: 80)

                    Text(character.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(character.selectedModelId)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }

            // Actions
            Section {
                Button {
                    Task {
                        await chatViewModel.startNewChat(character: character, modelContext: modelContext)
                        selectedChat = chatViewModel.currentChat
                    }
                } label: {
                    Label("New Chat", systemImage: "plus.message.fill")
                }

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
            }

            // Conversations
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
        .navigationTitle("Info")
        .navigationBarTitleDisplayMode(.inline)
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
            HStack {
                Text(chat.title.isEmpty ? "New Chat" : chat.title)
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                Text(chat.updatedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            if let firstMessage = chat.orderedMessages.first(where: { $0.role == .assistant }) {
                Text(firstMessage.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
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
