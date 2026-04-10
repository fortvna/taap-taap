import Foundation

public struct GameConfiguration: Sendable {
    public let rows: Int
    public let columns: Int
    public let startingLives: Int
    public let baseInterval: TimeInterval
    public let minimumInterval: TimeInterval
    public let speedRampFactor: Double

    public init(
        rows: Int = 6,
        columns: Int = 4,
        startingLives: Int = 3,
        baseInterval: TimeInterval = 1.0,
        minimumInterval: TimeInterval = 0.18,
        speedRampFactor: Double = 0.93
    ) {
        self.rows = rows
        self.columns = columns
        self.startingLives = startingLives
        self.baseInterval = baseInterval
        self.minimumInterval = minimumInterval
        self.speedRampFactor = speedRampFactor
    }

    public var tileCount: Int {
        rows * columns
    }
}
