import SwiftUI

struct ChatInputView: View {
    @Binding var userInput: String
    let isGenerating: Bool
    let onSend: () -> Void
    var onStop: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            TextField("Message...", text: $userInput, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
                .disabled(isGenerating)

            if isGenerating {
                Button(action: { onStop?() }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                }
            } else {
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .background(.bar)
    }
}

#Preview {
    VStack {
        Spacer()
        ChatInputView(
            userInput: .constant(""),
            isGenerating: false,
            onSend: {}
        )
    }
}
