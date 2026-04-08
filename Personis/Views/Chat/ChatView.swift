import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var chat: Chat
    @State var viewModel = ChatSessionViewModel()
    @State private var userInput = ""
    @State private var showingCharacterInfo = false
    @FocusState private var isInputFocused: Bool

    private var character: Character? { chat.character }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.displayMessages.enumerated()), id: \.element.id) { index, message in
                            let showDate = shouldShowDate(for: index)
                            if showDate {
                                DateSeparatorView(date: message.createdAt)
                            }

                            MessageBubbleView(message: message, character: character)
                                .id(message.id)
                        }

                        if !viewModel.streamingContent.isEmpty {
                            MessageBubbleView(
                                content: viewModel.streamingContent,
                                role: .assistant,
                                isStreaming: true,
                                character: character
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let character {
                    Button {
                        showingCharacterInfo = true
                    } label: {
                        HStack(spacing: 8) {
                            AvatarView(character: character, size: 30)
                            Text(character.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                    }
                } else {
                    Text(chat.title.isEmpty ? "Chat" : chat.title)
                        .font(.headline)
                }
            }
        }
        .sheet(isPresented: $showingCharacterInfo) {
            if let character {
                NavigationStack {
                    CharacterDetailView(character: character)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { showingCharacterInfo = false }
                            }
                        }
                }
            }
        }
        .onAppear {
            viewModel.loadExistingChat(chat)
        }
    }

    private func shouldShowDate(for index: Int) -> Bool {
        let messages = viewModel.displayMessages
        guard index < messages.count else { return false }
        if index == 0 { return true }
        let current = messages[index].createdAt
        let previous = messages[index - 1].createdAt
        return !Calendar.current.isDate(current, inSameDayAs: previous)
    }
}

struct DateSeparatorView: View {
    let date: Date

    var body: some View {
        Text(formattedDate)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
    }

    private var formattedDate: String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(.dateTime.month().day().year())
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
