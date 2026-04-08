import SwiftUI

struct CharacterRow: View {
    let character: Character

    private var lastMessage: Message? {
        let allChats = character.chats ?? []
        return allChats
            .flatMap { $0.orderedMessages }
            .filter { $0.role != .system }
            .max { $0.createdAt < $1.createdAt }
    }

    private var lastMessageDate: Date {
        lastMessage?.createdAt ?? character.updatedAt
    }

    private var lastMessagePreview: String {
        guard let msg = lastMessage else { return "No messages yet" }
        let prefix = msg.role == .user ? "You: " : ""
        return prefix + msg.content
    }

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(character: character, size: 54)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(character.name)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    Text(lastMessageDate, style: .relative)
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }

                Text(lastMessagePreview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        CharacterRow(character: Character(
            name: "Sherlock Holmes",
            systemPrompt: "You are Sherlock Holmes...",
            selectedModelId: "anthropic/claude-sonnet-4"
        ))
    }
}
