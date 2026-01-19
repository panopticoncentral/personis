import SwiftUI

struct CharacterRow: View {
    let character: Character

    var chatCount: Int {
        character.chats?.count ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(character.name)
                .font(.headline)

            Text("\(chatCount) \(chatCount == 1 ? "chat" : "chats")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CharacterRow(character: Character(
        name: "Sherlock Holmes",
        systemPrompt: "You are Sherlock Holmes...",
        selectedModelId: "anthropic/claude-sonnet-4"
    ))
}
