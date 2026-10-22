import Foundation

public struct LeaderboardEntry: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let playerID: UUID
    public let playerName: String
    public let score: Int
    public let tapCount: Int
    public let maxMultiplier: Int
    public let mode: GameMode?
    public let bestStreak: Int?
    public let accuracy: Double?
    public let playedAt: Date

    public init(
        id: UUID = UUID(),
        playerID: UUID,
        playerName: String,
        score: Int,
        tapCount: Int,
        maxMultiplier: Int,
        mode: GameMode = .classic,
        bestStreak: Int = 0,
        accuracy: Double = 1,
        playedAt: Date = .now
    ) {
        self.id = id
        self.playerID = playerID
        self.playerName = playerName
        self.score = score
        self.tapCount = tapCount
        self.maxMultiplier = maxMultiplier
        self.mode = mode
        self.bestStreak = bestStreak
        self.accuracy = accuracy
        self.playedAt = playedAt
    }
}
