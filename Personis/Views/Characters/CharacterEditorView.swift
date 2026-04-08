import SwiftUI
import SwiftData
import PhotosUI

struct CharacterEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(CharacterListViewModel.self) private var viewModel

    let character: Character?

    @State private var name: String = ""
    @State private var systemPrompt: String = ""
    @State private var selectedModelId: String = "anthropic/claude-sonnet-4"
    @State private var openingLine: String = ""
    @State private var avatarImageData: Data?
    @State private var avatarItem: PhotosPickerItem?

    @State private var showingModelPicker = false

    private var isEditing: Bool { character != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 12) {
                        AvatarView(
                            name: name.isEmpty ? "?" : name,
                            avatarImageData: avatarImageData,
                            size: 80
                        )

                        HStack(spacing: 16) {
                            PhotosPicker(
                                selection: $avatarItem,
                                matching: .images
                            ) {
                                Text(avatarImageData == nil ? "Add Photo" : "Change Photo")
                                    .font(.subheadline)
                            }

                            if avatarImageData != nil {
                                Button(role: .destructive) {
                                    avatarImageData = nil
                                    avatarItem = nil
                                } label: {
                                    Text("Remove")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }

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
            .onChange(of: avatarItem) {
                Task {
                    if let item = avatarItem,
                       let data = try? await item.loadTransferable(type: Data.self) {
                        avatarImageData = data
                    }
                }
            }
            .onAppear {
                if let c = character {
                    name = c.name
                    systemPrompt = c.systemPrompt
                    selectedModelId = c.selectedModelId
                    openingLine = c.openingLine
                    avatarImageData = c.avatarImageData
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
            existing.avatarImageData = avatarImageData
            existing.updatedAt = Date()
        } else {
            let newCharacter = viewModel.createCharacter(
                name: name,
                systemPrompt: systemPrompt,
                modelId: selectedModelId,
                openingLine: openingLine,
                modelContext: modelContext
            )
            newCharacter.avatarImageData = avatarImageData
        }

        dismiss()
    }
}

#Preview {
    CharacterEditorView(character: nil)
        .environment(CharacterListViewModel())
        .modelContainer(for: Character.self, inMemory: true)
}
