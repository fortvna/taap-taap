import Foundation

public struct LeaderboardEntry: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let playerID: UUID
    public let playerName: String
    public let score: Int
    public let tapCount: Int
    public let maxMultiplier: Int
    public let playedAt: Date

    public init(
        id: UUID = UUID(),
        playerID: UUID,
        playerName: String,
        score: Int,
        tapCount: Int,
        maxMultiplier: Int,
        playedAt: Date = .now
    ) {
        self.id = id
        self.playerID = playerID
        self.playerName = playerName
        self.score = score
        self.tapCount = tapCount
        self.maxMultiplier = maxMultiplier
        self.playedAt = playedAt
    }
}
