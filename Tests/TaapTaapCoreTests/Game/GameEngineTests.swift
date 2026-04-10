import Testing
@testable import TaapTaapCore

struct GameEngineTests {
    @Test
    func correctTapIncrementsTapCountAndMultiplier() {
        let engine = GameEngine(
            configuration: .init(rows: 2, columns: 2, baseInterval: 1.0, minimumInterval: 0.2, speedRampFactor: 0.9),
            now: .distantPast,
            tilePicker: { _, _ in 0 }
        )

        let outcome = engine.handleTap(on: 0, now: .distantPast)

        #expect(outcome == .correct)
        #expect(engine.state.tapCount == 1)
        #expect(engine.state.multiplier == 2)
        #expect(engine.state.maxMultiplier == 2)
        #expect(engine.state.jumpInterval == 0.9)
    }

    @Test
    func timeoutReducesLifeAndEndsGame() {
        let engine = GameEngine(
            configuration: .init(rows: 1, columns: 2, startingLives: 1, baseInterval: 1.0),
            now: .distantPast,
            tilePicker: { _, _ in 0 }
        )

        engine.update(now: .distantFuture)

        #expect(engine.state.isGameOver)
        #expect(!engine.state.isRunning)
        #expect(engine.state.livesRemaining == 0)
    }
}
