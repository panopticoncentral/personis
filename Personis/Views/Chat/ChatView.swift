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

struct NewChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let character: Character

    @State private var viewModel = ChatSessionViewModel()
    @State private var userInput = ""
    @State private var hasStarted = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        if let chat = viewModel.currentChat {
            ChatView(chat: chat, viewModel: viewModel)
        } else if hasStarted {
            ProgressView("Starting chat...")
                .navigationTitle("New Chat")
                .navigationBarTitleDisplayMode(.inline)
        } else {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.tint)

                    Text(character.name)
                        .font(.title2.bold())
                }
                .padding(.top, 40)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Start a conversation")
                        .font(.headline)

                    TextField("Type your message...", text: $userInput, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                        .focused($isInputFocused)
                }
                .padding(.horizontal)

                Spacer()

                Button {
                    hasStarted = true
                    Task {
                        await viewModel.startNewChat(
                            character: character,
                            modelContext: modelContext
                        )
                        await viewModel.sendMessage(userInput, modelContext: modelContext)
                    }
                } label: {
                    Text("Send")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isInputFocused = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        NewChatView(character: Character(
            name: "Sherlock Holmes",
            systemPrompt: "You are Sherlock Holmes, the famous detective.",
            selectedModelId: "anthropic/claude-sonnet-4"
        ))
    }
    .modelContainer(for: [Character.self, Chat.self, Message.self], inMemory: true)
}
