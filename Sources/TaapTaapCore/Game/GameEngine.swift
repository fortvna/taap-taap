import Foundation

public enum TapOutcome: Equatable, Sendable {
    case correct, incorrect, ignored
}

/// Mutable session state. Confine an engine to one actor (the app uses MainActor).
public final class GameEngine {
    public typealias TilePicker = (_ tileCount: Int, _ currentIndex: Int?) -> Int
    public typealias PowerUpPicker = (_ available: [PowerUp]) -> PowerUp

    public let configuration: GameConfiguration
    public private(set) var state: GameState
    private let tilePicker: TilePicker
    private let powerUpPicker: PowerUpPicker
    private var lastUpdate: Date
    private var pendingPowerUp = false

    public init(
        configuration: GameConfiguration = .init(),
        now: Date = .now,
        tilePicker: @escaping TilePicker = GameEngine.defaultTilePicker,
        powerUpPicker: @escaping PowerUpPicker = { $0.randomElement()! }
    ) {
        self.configuration = configuration
        self.tilePicker = tilePicker
        self.powerUpPicker = powerUpPicker
        self.lastUpdate = now
        self.state = GameState(configuration: configuration, now: now)
        start(now: now)
    }

    public func start(now: Date = .now) {
        state = GameState(configuration: configuration, now: now)
        lastUpdate = now
        pendingPowerUp = false
        moveTile(initial: true)
        refreshDeadline(now: now)
    }

    @discardableResult
    public func handleTap(on tileIndex: Int, now: Date = .now) -> TapOutcome {
        guard state.isRunning, !state.isPaused,
              (0..<configuration.tileCount).contains(tileIndex) else { return .ignored }
        // Resolve time first, including taps arriving between display timer ticks.
        let missesBeforeUpdate = state.misses
        update(now: now)
        guard state.isRunning else { return .ignored }
        guard state.misses == missesBeforeUpdate else { return .incorrect }
        guard tileIndex == state.activeTileIndex else {
            penalize()
            refreshDeadline(now: now)
            return .incorrect
        }

        let reactionBonus = Int((state.targetProgress * 50).rounded())
        state.tapCount += 1
        state.streak += 1
        state.bestStreak = max(state.bestStreak, state.streak)
        state.multiplier = min(8, 1 + state.streak / 5)
        state.maxMultiplier = max(state.maxMultiplier, state.multiplier)
        state.lastPoints = (100 + reactionBonus) * state.multiplier
        state.score += state.lastPoints
        state.lastReward = state.powerUp
        state.feedback = reactionBonus >= 40 ? "PERFECT" : "NICE TAP"
        if let powerUp = state.powerUp { collect(powerUp) }
        state.feedbackID += 1
        pendingPowerUp = state.tapCount.isMultiple(of: configuration.powerUpFrequency)
        accelerate()
        moveTile()
        refreshDeadline(now: now)
        return .correct
    }

    public func update(now: Date = .now) {
        guard state.isRunning, !state.isPaused, now > lastUpdate else { return }
        var delta = now.timeIntervalSince(lastUpdate)
        lastUpdate = now
        // Integrate at event boundaries so slow motion lasts exactly five real
        // seconds and a late display tick cannot grant extra lives or run time.
        while delta > 0.000_001 && state.isRunning {
            let rate = state.slowdownRemaining > 0 ? 0.5 : 1.0
            var step = min(delta, state.targetTimeRemaining / rate)
            if state.slowdownRemaining > 0 { step = min(step, state.slowdownRemaining) }
            if let remaining = state.timeRemaining { step = min(step, remaining) }
            state.elapsedTime += step
            state.targetTimeRemaining = max(0, state.targetTimeRemaining - step * rate)
            state.slowdownRemaining = max(0, state.slowdownRemaining - step)
            if let remaining = state.timeRemaining { state.timeRemaining = max(0, remaining - step) }
            delta -= step
            if let remaining = state.timeRemaining, remaining <= 0.000_001 {
                finish()
            } else if state.targetTimeRemaining <= 0.000_001 {
                penalize()
            }
        }
        refreshDeadline(now: now)
    }

    public func pause(now: Date = .now) {
        update(now: now)
        guard state.isRunning else { return }
        state.isPaused = true
    }

    public func resume(now: Date = .now) {
        guard state.isRunning, state.isPaused else { return }
        state.isPaused = false
        lastUpdate = now
        refreshDeadline(now: now)
    }

    public func finish() {
        state.isRunning = false
        state.isGameOver = true
        state.isPaused = false
    }

    private func collect(_ powerUp: PowerUp) {
        state.feedback = powerUp.title.uppercased()
        switch powerUp {
        case .extraLife: state.livesRemaining = min(5, state.livesRemaining + 1)
        case .slowdown: state.slowdownRemaining = 5
        case .shield: state.hasShield = true
        }
    }

    private func penalize() {
        state.misses += 1
        state.lastPoints = 0
        state.lastReward = nil
        state.feedbackID += 1
        if state.hasShield {
            state.hasShield = false
            state.feedback = "SHIELD SAVED YOU"
        } else {
            state.streak = 0
            state.multiplier = 1
            state.feedback = configuration.mode == .zen ? "FIND YOUR RHYTHM" : "COMBO LOST"
            if configuration.mode == .classic { state.livesRemaining -= 1 }
        }
        if state.livesRemaining <= 0 { finish(); return }
        accelerate()
        moveTile()
    }

    private func accelerate() {
        state.jumpInterval = max(configuration.minimumInterval, state.jumpInterval * configuration.speedRampFactor)
    }

    private func moveTile(initial: Bool = false) {
        let previous: Int? = initial ? nil : state.activeTileIndex
        let picked = tilePicker(configuration.tileCount, previous)
        state.activeTileIndex = (0..<configuration.tileCount).contains(picked) ? picked : 0
        if configuration.tileCount > 1 && state.activeTileIndex == previous {
            state.activeTileIndex = ((previous ?? 0) + 1) % configuration.tileCount
        }
        state.targetTimeRemaining = state.jumpInterval
        state.powerUp = nil
        if pendingPowerUp {
            let available: [PowerUp] = configuration.mode == .classic ? PowerUp.allCases : [.slowdown, .shield]
            let picked = powerUpPicker(available)
            state.powerUp = available.contains(picked) ? picked : available[0]
            pendingPowerUp = false
        }
    }

    private func refreshDeadline(now: Date) {
        let slowedPortion = min(state.targetTimeRemaining, state.slowdownRemaining * 0.5)
        state.currentDeadline = now.addingTimeInterval(slowedPortion * 2 + state.targetTimeRemaining - slowedPortion)
    }

    public static func defaultTilePicker(tileCount: Int, currentIndex: Int?) -> Int {
        guard tileCount > 1 else { return 0 }
        guard let currentIndex else { return Int.random(in: 0..<tileCount) }
        let candidate = Int.random(in: 0..<(tileCount - 1))
        return candidate >= currentIndex ? candidate + 1 : candidate
    }
}
