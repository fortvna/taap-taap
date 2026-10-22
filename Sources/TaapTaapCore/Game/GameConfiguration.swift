import Foundation

public struct GameConfiguration: Sendable {
    public let rows: Int
    public let columns: Int
    public let startingLives: Int
    public let baseInterval: TimeInterval
    public let minimumInterval: TimeInterval
    public let speedRampFactor: Double
    public let mode: GameMode
    public let duration: TimeInterval?
    public let powerUpFrequency: Int

    public init(
        rows: Int = 6,
        columns: Int = 4,
        startingLives: Int = 3,
        baseInterval: TimeInterval = 5,
        minimumInterval: TimeInterval = 0.45,
        speedRampFactor: Double = 0.95,
        mode: GameMode = .classic,
        duration: TimeInterval? = nil,
        powerUpFrequency: Int = 8
    ) {
        precondition(rows > 0 && columns > 0 && rows <= 12 && columns <= 12)
        precondition(startingLives > 0 && startingLives <= 5)
        precondition(baseInterval.isFinite && minimumInterval.isFinite)
        precondition(minimumInterval > 0 && baseInterval >= minimumInterval)
        precondition(speedRampFactor > 0 && speedRampFactor <= 1)
        precondition(duration == nil || (duration!.isFinite && duration! > 0))
        precondition(powerUpFrequency > 0)
        self.rows = rows
        self.columns = columns
        self.startingLives = startingLives
        self.baseInterval = baseInterval
        self.minimumInterval = mode == .zen ? min(baseInterval, max(1, minimumInterval)) : minimumInterval
        self.speedRampFactor = speedRampFactor
        self.mode = mode
        self.duration = mode == .rush ? (duration ?? 60) : duration
        self.powerUpFrequency = powerUpFrequency
    }

    public var tileCount: Int { rows * columns }
}
