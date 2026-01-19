import Foundation
import SwiftData

@Model
final class Chat {
    var id: UUID = UUID()
    var title: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var modelIdSnapshot: String = ""

    var character: Character?

    @Relationship(deleteRule: .cascade, inverse: \Message.chat)
    var messages: [Message]?

    var orderedMessages: [Message] {
        (messages ?? []).sorted { $0.orderIndex < $1.orderIndex }
    }

    init(title: String, character: Character, modelIdSnapshot: String) {
        self.id = UUID()
        self.title = title
        self.character = character
        self.modelIdSnapshot = modelIdSnapshot
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
