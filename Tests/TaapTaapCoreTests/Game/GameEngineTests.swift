import Foundation
import Testing
@testable import TaapTaapCore

struct GameEngineTests {
    private let start = Date(timeIntervalSince1970: 1_000)

    private func engine(mode: GameMode = .classic, lives: Int = 3,
                        power: PowerUp = .slowdown, frequency: Int = 8) -> GameEngine {
        GameEngine(configuration: .init(startingLives: lives, mode: mode, powerUpFrequency: frequency),
                   now: start, tilePicker: { count, current in ((current ?? -1) + 1) % count },
                   powerUpPicker: { available in available.contains(power) ? power : available[0] })
    }
    private func hit(_ engine: GameEngine, at date: Date? = nil) {
        engine.handleTap(on: engine.state.activeTileIndex, now: date ?? start)
    }

    @Test func startsWithFiveSecondsAndThreeLives() {
        let game = engine()
        #expect(game.state.targetTimeRemaining == 5)
        #expect(game.state.livesRemaining == 3)
        #expect(game.state.score == 0)
        #expect(game.state.currentDeadline == start.addingTimeInterval(5))
    }

    @Test func correctTapMovesTargetAndAccumulatesPoints() {
        let game = engine()
        let original = game.state.activeTileIndex
        hit(game)
        #expect(game.state.activeTileIndex != original)
        #expect(game.state.tapCount == 1)
        #expect(game.state.score == 150)
        #expect(game.state.jumpInterval == 4.75)
        hit(game)
        #expect(game.state.score == 300)
    }

    @Test func reactionTimeChangesBonus() {
        let fast = engine()
        let slow = engine()
        hit(fast)
        hit(slow, at: start.addingTimeInterval(4))
        #expect(fast.state.score == 150)
        #expect(slow.state.score == 110)
    }

    @Test func comboGrowsEveryFiveHitsAndIsCapped() {
        let game = engine()
        for _ in 0..<50 { hit(game) }
        #expect(game.state.multiplier == 8)
        #expect(game.state.maxMultiplier == 8)
        #expect(game.state.bestStreak == 50)
    }

    @Test func wrongTapResetsComboButNeverRemovesEarnedScore() {
        let game = engine()
        for _ in 0..<5 { hit(game) }
        let earned = game.state.score
        game.handleTap(on: (game.state.activeTileIndex + 1) % 16, now: start)
        #expect(game.state.score == earned)
        #expect(game.state.streak == 0)
        #expect(game.state.multiplier == 1)
        #expect(game.state.livesRemaining == 2)
        #expect(game.state.bestStreak == 5)
    }

    @Test func tapAtDeadlineCannotScoreAnExpiredTarget() {
        let game = engine()
        let target = game.state.activeTileIndex
        #expect(game.handleTap(on: target, now: start.addingTimeInterval(5)) == .incorrect)
        #expect(game.state.tapCount == 0)
        #expect(game.state.livesRemaining == 2)
        #expect(game.state.activeTileIndex != target)
    }

    @Test func longTimerGapProcessesAllExpiredTargets() {
        let game = engine()
        game.update(now: start.addingTimeInterval(20))
        #expect(game.state.isGameOver)
        #expect(game.state.livesRemaining == 0)
        #expect(game.state.misses == 3)
        #expect(game.handleTap(on: game.state.activeTileIndex, now: start.addingTimeInterval(21)) == .ignored)
    }

    @Test func timeoutAlsoAcceleratesTheBounce() {
        let game = engine()
        game.update(now: start.addingTimeInterval(5))
        #expect(game.state.jumpInterval == 4.75)
        #expect(game.state.targetTimeRemaining == 4.75)
    }

    @Test func speedNeverDropsBelowFloor() {
        let game = engine()
        for _ in 0..<200 { hit(game) }
        #expect(game.state.jumpInterval == 0.45)
        let zen = engine(mode: .zen)
        for _ in 0..<200 { hit(zen) }
        #expect(zen.state.jumpInterval == 1)
    }

    @Test func boostAppearsAfterEightHitsAndIsCollectedOnNextHit() {
        let game = engine(power: .extraLife)
        for _ in 0..<8 { hit(game) }
        #expect(game.state.powerUp == .extraLife)
        #expect(game.state.livesRemaining == 3)
        hit(game)
        #expect(game.state.lastReward == .extraLife)
        #expect(game.state.livesRemaining == 4)
        #expect(game.state.powerUp == nil)
    }

    @Test func missedBoostIsNotAwardedOrRepeated() {
        let game = engine(power: .extraLife)
        for _ in 0..<8 { hit(game) }
        game.update(now: game.state.currentDeadline)
        #expect(game.state.powerUp == nil)
        #expect(game.state.livesRemaining == 2)
        hit(game, at: game.state.currentDeadline.addingTimeInterval(-1))
        #expect(game.state.lastReward == nil)
    }

    @Test func extraLivesAreCapped() {
        let game = engine(power: .extraLife, frequency: 1)
        for _ in 0..<12 { hit(game) }
        #expect(game.state.livesRemaining == 5)
    }

    @Test func slowMotionLastsFiveRealSecondsWithoutSlowingRushClock() {
        let game = engine(mode: .rush, frequency: 1)
        hit(game)
        hit(game)
        let interval = game.state.targetTimeRemaining
        game.update(now: start.addingTimeInterval(4))
        #expect(abs(game.state.targetTimeRemaining - (interval - 2)) < 0.00001)
        #expect(game.state.slowdownRemaining == 1)
        #expect(game.state.timeRemaining == 56)
        game.update(now: start.addingTimeInterval(5.5))
        #expect(game.state.slowdownRemaining == 0)
        #expect(abs(game.state.targetTimeRemaining - (interval - 3)) < 0.00001)
    }

    @Test func slowDeadlineAccountsForEffectExpiringBeforeTarget() {
        let game = engine(frequency: 1)
        hit(game)
        hit(game)
        #expect(abs(game.state.currentDeadline.timeIntervalSince(start) - (game.state.jumpInterval + 2.5)) < 0.00001)
    }

    @Test func shieldAbsorbsOnePenaltyAndPreservesCombo() {
        let game = engine(power: .shield)
        for _ in 0..<9 { hit(game) }
        #expect(game.state.hasShield)
        game.handleTap(on: (game.state.activeTileIndex + 1) % 16, now: start)
        #expect(!game.state.hasShield)
        #expect(game.state.livesRemaining == 3)
        #expect(game.state.streak == 9)
        game.handleTap(on: (game.state.activeTileIndex + 1) % 16, now: start)
        #expect(game.state.livesRemaining == 2)
        #expect(game.state.streak == 0)
    }

    @Test func pauseFreezesTargetEffectsAndMatchClock() {
        let game = engine(mode: .rush, frequency: 1)
        hit(game); hit(game)
        game.pause(now: start.addingTimeInterval(1))
        let remaining = game.state.targetTimeRemaining
        game.update(now: start.addingTimeInterval(100))
        #expect(game.state.targetTimeRemaining == remaining)
        #expect(game.state.timeRemaining == 59)
        #expect(game.state.slowdownRemaining == 4)
        #expect(game.handleTap(on: game.state.activeTileIndex, now: start.addingTimeInterval(100)) == .ignored)
        game.resume(now: start.addingTimeInterval(100))
        game.update(now: start.addingTimeInterval(101))
        #expect(game.state.timeRemaining == 58)
        #expect(game.state.slowdownRemaining == 3)
    }

    @Test func rushEndsAtSixtySecondsDespiteMisses() {
        let game = engine(mode: .rush)
        game.update(now: start.addingTimeInterval(59))
        #expect(game.state.isRunning)
        #expect(game.state.livesRemaining == 3)
        game.update(now: start.addingTimeInterval(60))
        #expect(game.state.isGameOver)
        #expect(game.state.elapsedTime == 60)
        #expect(game.state.timeRemaining == 0)
    }

    @Test func zenHasNoLifeOrTimeLimitAndCanBeFinished() {
        let game = engine(mode: .zen)
        game.update(now: start.addingTimeInterval(120))
        #expect(game.state.isRunning)
        #expect(game.state.timeRemaining == nil)
        #expect(game.state.livesRemaining == 3)
        game.finish()
        #expect(game.state.isGameOver)
    }

    @Test func restartingClearsAllTransientState() {
        let game = engine(power: .shield, frequency: 1)
        for _ in 0..<10 { hit(game) }
        game.pause(now: start)
        game.start(now: start.addingTimeInterval(50))
        #expect(game.state.score == 0)
        #expect(game.state.tapCount == 0)
        #expect(!game.state.hasShield)
        #expect(!game.state.isPaused)
        #expect(game.state.powerUp == nil)
        #expect(game.state.currentDeadline == start.addingTimeInterval(55))
    }

    @Test func invalidTileIndicesAreIgnored() {
        let game = engine()
        #expect(game.handleTap(on: -1, now: start) == .ignored)
        #expect(game.handleTap(on: 16, now: start) == .ignored)
        #expect(game.state.livesRemaining == 3)
    }

    @Test func pickerCannotRepeatTheSameTarget() {
        let game = GameEngine(now: start, tilePicker: { _, _ in 0 })
        let first = game.state.activeTileIndex
        hit(game)
        #expect(game.state.activeTileIndex != first)
    }

    @Test func timerChunkSizeDoesNotChangeGameOutcome() {
        let stepped = engine(mode: .rush)
        let single = engine(mode: .rush)
        for tick in 1...300 { stepped.update(now: start.addingTimeInterval(Double(tick) / 10)) }
        single.update(now: start.addingTimeInterval(30))
        #expect(stepped.state.misses == single.state.misses)
        #expect(abs(stepped.state.targetTimeRemaining - single.state.targetTimeRemaining) < 0.00001)
        #expect(abs((stepped.state.timeRemaining ?? 0) - (single.state.timeRemaining ?? 0)) < 0.00001)
    }
}
