import Foundation
import SwiftData

enum MessageRole: String, Codable {
    case system
    case user
    case assistant
}

@Model
final class Message {
    var id: UUID = UUID()
    var content: String = ""
    var roleRawValue: String = MessageRole.user.rawValue
    var orderIndex: Int = 0
    var createdAt: Date = Date()

    var chat: Chat?

    var role: MessageRole {
        get { MessageRole(rawValue: roleRawValue) ?? .user }
        set { roleRawValue = newValue.rawValue }
    }

    init(content: String, role: MessageRole, orderIndex: Int, chat: Chat? = nil) {
        self.id = UUID()
        self.content = content
        self.roleRawValue = role.rawValue
        self.orderIndex = orderIndex
        self.chat = chat
        self.createdAt = Date()
    }
}
