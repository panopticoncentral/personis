import SwiftUI

struct AvatarView: View {
    let name: String
    let avatarImageData: Data?
    let size: CGFloat

    init(character: Character, size: CGFloat) {
        self.name = character.name
        self.avatarImageData = character.avatarImageData
        self.size = size
    }

    init(name: String, avatarImageData: Data? = nil, size: CGFloat) {
        self.name = name
        self.avatarImageData = avatarImageData
        self.size = size
    }

    private static let palette: [Color] = [
        .blue, .purple, .orange, .green, .pink, .teal, .indigo, .mint
    ]

    private var backgroundColor: Color {
        let hash = abs(name.hashValue)
        return Self.palette[hash % Self.palette.count]
    }

    private var initial: String {
        String(name.prefix(1)).uppercased()
    }

    var body: some View {
        if let data = avatarImageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            ZStack {
                Circle()
                    .fill(backgroundColor.gradient)
                Text(initial)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        AvatarView(name: "Sherlock Holmes", size: 50)
        AvatarView(name: "Ada Lovelace", size: 50)
        AvatarView(name: "Marcus Aurelius", size: 50)
        AvatarView(name: "Socrates", size: 40)
    }
}
