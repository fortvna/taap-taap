import Foundation

public struct GameState: Sendable {
    public var isRunning: Bool
    public var isGameOver: Bool
    public var activeTileIndex: Int
    public var tapCount: Int
    public var multiplier: Int
    public var maxMultiplier: Int
    public var jumpInterval: TimeInterval
    public var livesRemaining: Int
    public var currentDeadline: Date

    public init(configuration: GameConfiguration, now: Date) {
        self.isRunning = true
        self.isGameOver = false
        self.activeTileIndex = 0
        self.tapCount = 0
        self.multiplier = 1
        self.maxMultiplier = 1
        self.jumpInterval = configuration.baseInterval
        self.livesRemaining = configuration.startingLives
        self.currentDeadline = now
    }

    public var score: Int {
        tapCount * maxMultiplier
    }
}
