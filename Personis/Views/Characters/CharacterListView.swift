import SwiftUI
import SwiftData

struct CharacterListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CharacterListViewModel.self) private var viewModel

    @Query(sort: \Character.name) private var characters: [Character]

    @State private var selectedCharacter: Character?
    @State private var showingEditor = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(characters) { character in
                    CharacterRow(character: character)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCharacter = character
                        }
                }
                .onDelete(perform: deleteCharacters)
            }
            .navigationTitle("Characters")
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
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(item: $selectedCharacter) { character in
                CharacterDetailView(character: character)
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
                        "No Characters Yet",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("Tap the + button to create your first character")
                    )
                }
            }
            .task {
                viewModel.seedDefaultCharactersIfNeeded(modelContext: modelContext)
                await viewModel.loadModels()
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
