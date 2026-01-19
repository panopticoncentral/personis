import Foundation
import SwiftData

@Model
final class Character {
    var id: UUID = UUID()
    var name: String = ""
    var systemPrompt: String = ""
    var selectedModelId: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \Chat.character)
    var chats: [Chat]?

    init(name: String, systemPrompt: String, selectedModelId: String) {
        self.id = UUID()
        self.name = name
        self.systemPrompt = systemPrompt
        self.selectedModelId = selectedModelId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
