import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var viewModel = OnboardingViewModel()
    @FocusState private var isAPIKeyFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(.tint)

                        Text("Welcome to Personae")
                            .font(.largeTitle.bold())

                        Text("Chat with AI characters through role-play")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)

                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(
                            icon: "theatermasks.fill",
                            title: "Create Characters",
                            description: "Design unique AI personas with custom personalities"
                        )
                        FeatureRow(
                            icon: "bubble.left.and.bubble.right.fill",
                            title: "Have Conversations",
                            description: "Chat naturally with your characters in role-play"
                        )
                        FeatureRow(
                            icon: "cpu.fill",
                            title: "Choose Your Model",
                            description: "Pick from hundreds of AI models via OpenRouter"
                        )
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Connect to OpenRouter")
                            .font(.headline)

                        Text("Personae uses OpenRouter to access AI models. Enter your API key to get started.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        SecureField("sk-or-...", text: $viewModel.apiKey)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .focused($isAPIKeyFocused)

                        if let error = viewModel.validationError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        Link("Get your API key at openrouter.ai",
                             destination: URL(string: "https://openrouter.ai/keys")!)
                            .font(.caption)
                    }
                    .padding(.horizontal)

                    Button {
                        Task {
                            if await viewModel.validateAndSave() {
                                onComplete()
                            }
                        }
                    } label: {
                        Group {
                            if viewModel.isValidating {
                                ProgressView()
                            } else {
                                Text("Get Started")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!viewModel.canSubmit)
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
