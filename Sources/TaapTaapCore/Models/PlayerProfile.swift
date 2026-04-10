import Foundation

public struct PlayerProfile: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var tileColor: TileColor
    public var gamesPlayed: Int
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        tileColor: TileColor,
        gamesPlayed: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.tileColor = tileColor
        self.gamesPlayed = gamesPlayed
        self.createdAt = createdAt
    }
}
