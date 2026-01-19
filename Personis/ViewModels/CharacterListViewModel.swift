import Foundation
import SwiftData

@Observable
final class CharacterListViewModel {
    var availableModels: [OpenRouterModel] = []
    var isLoadingModels: Bool = false
    var modelsError: String?

    private let openRouter = OpenRouterService.shared

    @MainActor
    func loadModels() async {
        guard availableModels.isEmpty else { return }

        isLoadingModels = true
        modelsError = nil

        do {
            availableModels = try await openRouter.fetchModels()
        } catch {
            modelsError = error.localizedDescription
        }

        isLoadingModels = false
    }

    func createCharacter(
        name: String,
        systemPrompt: String,
        modelId: String,
        modelContext: ModelContext
    ) -> Character {
        let character = Character(
            name: name,
            systemPrompt: systemPrompt,
            selectedModelId: modelId
        )
        modelContext.insert(character)
        return character
    }

    func deleteCharacter(_ character: Character, modelContext: ModelContext) {
        modelContext.delete(character)
    }

    @MainActor
    func seedDefaultCharactersIfNeeded(modelContext: ModelContext) {
        DefaultCharactersService.seedIfEmpty(modelContext: modelContext)
    }
}
