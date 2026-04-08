import SwiftUI
import SwiftData

struct CharacterListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CharacterListViewModel.self) private var viewModel

    @Query(sort: \Character.updatedAt, order: .reverse) private var characters: [Character]

    @State private var selectedChat: Chat?
    @State private var showingEditor = false
    @State private var showingSettings = false
    @State private var chatViewModel = ChatSessionViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(characters) { character in
                    CharacterRow(character: character)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            navigateToChat(for: character)
                        }
                }
                .onDelete(perform: deleteCharacters)
            }
            .listStyle(.plain)
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingEditor = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .navigationDestination(item: $selectedChat) { chat in
                ChatView(chat: chat)
            }
            .sheet(isPresented: $showingEditor) {
                CharacterEditorView(character: nil)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .overlay {
                if characters.isEmpty {
                    ContentUnavailableView(
                        "No Messages",
                        systemImage: "bubble.left.and.text.bubble.right",
                        description: Text("Tap the compose button to start a new conversation")
                    )
                }
            }
            .task {
                viewModel.seedDefaultCharactersIfNeeded(modelContext: modelContext)
                await viewModel.loadModels()
            }
        }
    }

    private func navigateToChat(for character: Character) {
        let sortedChats = (character.chats ?? []).sorted { $0.updatedAt > $1.updatedAt }
        if let mostRecent = sortedChats.first {
            selectedChat = mostRecent
        } else {
            Task {
                await chatViewModel.startNewChat(character: character, modelContext: modelContext)
                selectedChat = chatViewModel.currentChat
            }
        }
    }

    private func deleteCharacters(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteCharacter(characters[index], modelContext: modelContext)
        }
    }
}

#Preview {
    CharacterListView()
        .environment(CharacterListViewModel())
        .modelContainer(for: Character.self, inMemory: true)
}
