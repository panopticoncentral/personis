import SwiftUI

struct MessageBubbleView: View {
    let content: String
    let role: MessageRole
    var isStreaming: Bool = false

    init(message: Message) {
        self.content = message.content
        self.role = message.role
        self.isStreaming = false
    }

    init(content: String, role: MessageRole, isStreaming: Bool = false) {
        self.content = content
        self.role = role
        self.isStreaming = isStreaming
    }

    var body: some View {
        HStack {
            if role == .user {
                Spacer(minLength: 60)
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
                content: "Ah, an excellent question! My methods rely primarily on careful observation and logical deduction. You see, most people look but do not observe. The distinction is clear...",
                role: .assistant,
                isStreaming: true
            )
        }
        .padding()
    }
}
