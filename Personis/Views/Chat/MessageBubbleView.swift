import SwiftUI

struct MessageBubbleView: View {
    let content: String
    let role: MessageRole
    var isStreaming: Bool = false
    var character: Character?

    init(message: Message, character: Character? = nil) {
        self.content = message.content
        self.role = message.role
        self.isStreaming = false
        self.character = character
    }

    init(content: String, role: MessageRole, isStreaming: Bool = false, character: Character? = nil) {
        self.content = content
        self.role = role
        self.isStreaming = isStreaming
        self.character = character
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if role == .user {
                Spacer(minLength: 60)
            }

            if role == .assistant {
                if let character {
                    AvatarView(character: character, size: 28)
                } else {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 28, height: 28)
                }
            }

            VStack(alignment: role == .user ? .trailing : .leading, spacing: 4) {
                Text(content)
                    .padding(12)
                    .background(role == .user ? Color.accentColor : Color(.systemGray5))
                    .foregroundStyle(role == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .textSelection(.enabled)

                if isStreaming {
                    HStack(spacing: 4) {
                        Circle()
                            .frame(width: 4, height: 4)
                        Circle()
                            .frame(width: 4, height: 4)
                        Circle()
                            .frame(width: 4, height: 4)
                    }
                    .foregroundStyle(.secondary)
                    .opacity(0.6)
                }
            }

            if role == .assistant {
                Spacer(minLength: 60)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 8) {
            MessageBubbleView(
                content: "Hello! How can I help you today?",
                role: .assistant
            )

            MessageBubbleView(
                content: "I'd like to know more about your detective methods.",
                role: .user
            )

            MessageBubbleView(
                content: "Ah, an excellent question!",
                role: .assistant,
                isStreaming: true
            )
        }
        .padding()
    }
}
