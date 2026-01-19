import SwiftUI

struct ChatInputView: View {
    @Binding var userInput: String
    let isGenerating: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Message...", text: $userInput, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
                .disabled(isGenerating)

            Button(action: onSend) {
                if isGenerating {
                    ProgressView()
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
            }
            .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
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
