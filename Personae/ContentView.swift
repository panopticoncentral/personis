import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var hasCompletedOnboarding = false
    @State private var isCheckingAuth = true
    @State private var characterListViewModel = CharacterListViewModel()

    var body: some View {
        Group {
            if isCheckingAuth {
                ProgressView("Loading...")
            } else if hasCompletedOnboarding {
                CharacterListView()
                    .environment(characterListViewModel)
            } else {
                OnboardingView(onComplete: {
                    hasCompletedOnboarding = true
                })
            }
        }
        .task {
            let keychain = KeychainService.shared
            hasCompletedOnboarding = await keychain.hasAPIKey()
            isCheckingAuth = false
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Character.self, Chat.self, Message.self], inMemory: true)
}
