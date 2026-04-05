import SwiftUI
import SwiftData

@main
struct PersonisApp: App {
    let sharedModelContainer: ModelContainer?
    @State private var containerError: String?

    init() {
        let schema = Schema([
            Character.self,
            Chat.self,
            Message.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            self.sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            self.sharedModelContainer = nil
            self._containerError = State(initialValue: "Failed to load data: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container = sharedModelContainer {
                ContentView()
                    .modelContainer(container)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.red)
                    Text("Unable to Load App Data")
                        .font(.title2.bold())
                    Text(containerError ?? "An unknown error occurred.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Text("Try deleting and reinstalling the app.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}
