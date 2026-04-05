import SwiftUI
import SwiftData

struct CharacterEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(CharacterListViewModel.self) private var viewModel

    let character: Character?

    @State private var name: String = ""
    @State private var systemPrompt: String = ""
    @State private var selectedModelId: String = "anthropic/claude-sonnet-4"
    @State private var openingLine: String = ""

    @State private var showingModelPicker = false

    private var isEditing: Bool { character != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Character name", text: $name)
                }

                Section("AI Model") {
                    Button {
                        showingModelPicker = true
                    } label: {
                        HStack {
                            Text("Model")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(selectedModelId)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Section {
                    TextEditor(text: $systemPrompt)
                        .frame(minHeight: 200)
                } header: {
                    Text("System Prompt")
                } footer: {
                    Text("Describe the character's personality, background, and how they should respond.")
                }

                Section {
                    TextField("e.g. \"Hello! How can I help you today?\"", text: $openingLine, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text("Opening Line")
                } footer: {
                    Text("Optional. The character will say this to start each new conversation.")
                }
            }
            .navigationTitle(isEditing ? "Edit Character" : "New Character")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.isEmpty || systemPrompt.isEmpty)
                }
            }
            .sheet(isPresented: $showingModelPicker) {
                ModelPickerView(selectedModelId: $selectedModelId)
            }
            .onAppear {
                if let c = character {
                    name = c.name
                    systemPrompt = c.systemPrompt
                    selectedModelId = c.selectedModelId
                    openingLine = c.openingLine
                }
            }
        }
    }

    private func save() {
        if let existing = character {
            existing.name = name
            existing.systemPrompt = systemPrompt
            existing.selectedModelId = selectedModelId
            existing.openingLine = openingLine
            existing.updatedAt = Date()
        } else {
            _ = viewModel.createCharacter(
                name: name,
                systemPrompt: systemPrompt,
                modelId: selectedModelId,
                openingLine: openingLine,
                modelContext: modelContext
            )
        }

        dismiss()
    }
}

#Preview {
    CharacterEditorView(character: nil)
        .environment(CharacterListViewModel())
        .modelContainer(for: Character.self, inMemory: true)
}
