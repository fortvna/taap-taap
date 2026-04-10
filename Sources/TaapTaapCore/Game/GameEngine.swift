import Foundation

public enum TapOutcome: Equatable, Sendable {
    case correct
    case incorrect
    case ignored
}

public final class GameEngine: @unchecked Sendable {
    public typealias TilePicker = (_ tileCount: Int, _ currentIndex: Int?) -> Int

    public let configuration: GameConfiguration
    public private(set) var state: GameState

    private let tilePicker: TilePicker

    public init(
        configuration: GameConfiguration = .init(),
        now: Date = .now,
        tilePicker: @escaping TilePicker = GameEngine.defaultTilePicker
    ) {
        self.configuration = configuration
        self.tilePicker = tilePicker
        self.state = GameState(configuration: configuration, now: now)
        start(now: now)
    }

    public func start(now: Date = .now) {
        state = GameState(configuration: configuration, now: now)
        state.activeTileIndex = tilePicker(configuration.tileCount, nil)
        state.currentDeadline = now.addingTimeInterval(state.jumpInterval)
    }

    @discardableResult
    public func handleTap(on tileIndex: Int, now: Date = .now) -> TapOutcome {
        guard state.isRunning, !state.isGameOver else {
            return .ignored
        }

        if tileIndex != state.activeTileIndex {
            penalize(now: now)
            return .incorrect
        }

        state.tapCount += 1
        state.multiplier += 1
        state.maxMultiplier = max(state.maxMultiplier, state.multiplier)
        state.jumpInterval = max(
            configuration.minimumInterval,
            state.jumpInterval * configuration.speedRampFactor
        )
        moveTile(now: now)
        return .correct
    }

    public func update(now: Date = .now) {
        guard state.isRunning, !state.isGameOver else { return }

        if now >= state.currentDeadline {
            penalize(now: now)
        }
    }

    private func penalize(now: Date) {
        state.livesRemaining -= 1
        state.multiplier = 1

        if state.livesRemaining <= 0 {
            state.isRunning = false
            state.isGameOver = true
            return
        }

        moveTile(now: now)
    }

    private func moveTile(now: Date) {
        let nextTile = tilePicker(configuration.tileCount, state.activeTileIndex)
        state.activeTileIndex = nextTile
        state.currentDeadline = now.addingTimeInterval(state.jumpInterval)
    }

    public static func defaultTilePicker(tileCount: Int, currentIndex: Int?) -> Int {
        guard tileCount > 1 else { return 0 }

        var candidate = Int.random(in: 0 ..< tileCount)
        while candidate == currentIndex {
            candidate = Int.random(in: 0 ..< tileCount)
        }
        return candidate
    }
}
