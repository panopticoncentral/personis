import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var chat: Chat
    @State var viewModel = ChatSessionViewModel()
    @State private var userInput = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.displayMessages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }

                        if !viewModel.streamingContent.isEmpty {
                            MessageBubbleView(
                                content: viewModel.streamingContent,
                                role: .assistant,
                                isStreaming: true
                            )
                            .id("streaming")
                        }

                        if let error = viewModel.error {
                            Text(error)
                                .foregroundStyle(.red)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding()
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.streamingContent) {
                    withAnimation {
                        proxy.scrollTo("streaming", anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.displayMessages.count) {
                    if let lastId = viewModel.displayMessages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            ChatInputView(
                userInput: $userInput,
                isGenerating: viewModel.isGenerating,
                onSend: {
                    let message = userInput
                    userInput = ""
                    Task {
                        await viewModel.sendMessage(message, modelContext: modelContext)
                    }
                },
                onStop: {
                    viewModel.cancelGeneration()
                }
            )
            .focused($isInputFocused)
        }
        .navigationTitle(chat.title.isEmpty ? "Chat" : chat.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadExistingChat(chat)
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(chat: Chat(
            title: "Test Chat",
            character: Character(
                name: "Sherlock Holmes",
                systemPrompt: "You are Sherlock Holmes, the famous detective.",
                selectedModelId: "anthropic/claude-sonnet-4"
            ),
            modelIdSnapshot: "anthropic/claude-sonnet-4"
        ))
    }
    .modelContainer(for: [Character.self, Chat.self, Message.self], inMemory: true)
}
