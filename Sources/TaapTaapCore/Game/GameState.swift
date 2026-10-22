import Foundation

public struct GameState: Sendable {
    public var isRunning = true
    public var isGameOver = false
    public var isPaused = false
    public var activeTileIndex = 0
    public var tapCount = 0
    public var misses = 0
    public var streak = 0
    public var bestStreak = 0
    public var multiplier = 1
    public var maxMultiplier = 1
    public var score = 0
    public var jumpInterval: TimeInterval
    public var targetTimeRemaining: TimeInterval
    public var livesRemaining: Int
    public var currentDeadline: Date
    public var elapsedTime: TimeInterval = 0
    public var timeRemaining: TimeInterval?
    public var slowdownRemaining: TimeInterval = 0
    public var hasShield = false
    public var powerUp: PowerUp?
    public var lastReward: PowerUp?
    public var lastPoints = 0
    public var feedbackID = 0
    public var feedback = "Follow the light"

    public init(configuration: GameConfiguration, now: Date) {
        jumpInterval = configuration.baseInterval
        targetTimeRemaining = configuration.baseInterval
        livesRemaining = configuration.startingLives
        currentDeadline = now.addingTimeInterval(configuration.baseInterval)
        timeRemaining = configuration.duration
    }

    public var targetProgress: Double {
        min(1, max(0, targetTimeRemaining / jumpInterval))
    }
    public var level: Int { 1 + tapCount / 10 }
    public var accuracy: Double {
        let attempts = tapCount + misses
        return attempts == 0 ? 1 : Double(tapCount) / Double(attempts)
    }
}
