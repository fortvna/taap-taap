import Combine
import Foundation
import TaapTaapCore
#if os(iOS)
import UIKit
#endif

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState
    private let engine: GameEngine
    private var timerCancellable: AnyCancellable?
    private var hasStarted = false
    // Wall-clock changes must not advance or rewind a game. Anchor Date to uptime.
    private let origin = Date.now
    private let originUptime = ProcessInfo.processInfo.systemUptime
    private var now: Date {
        origin.addingTimeInterval(ProcessInfo.processInfo.systemUptime - originUptime)
    }

    var rows: Int { engine.configuration.rows }
    var columns: Int { engine.configuration.columns }
    var mode: GameMode { engine.configuration.mode }

    init(mode: GameMode) {
        let engine = GameEngine(configuration: .init(mode: mode))
        self.engine = engine
        self.state = engine.state
    }

    func startIfNeeded() {
        guard !hasStarted else { return }
        start()
    }

    func start() {
        hasStarted = true
        engine.start(now: now)
        state = engine.state
        connectTimer()
    }

    func stop() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func pause() {
        engine.pause(now: now)
        state = engine.state
        stop()
    }

    func resume() {
        engine.resume(now: now)
        state = engine.state
        if state.isRunning { connectTimer() }
    }

    func finish() {
        engine.finish()
        state = engine.state
        stop()
    }

    func tap(tileIndex: Int) {
        let outcome = engine.handleTap(on: tileIndex, now: now)
        state = engine.state
        #if os(iOS)
        if outcome == .correct {
            UIImpactFeedbackGenerator(style: state.lastReward == nil ? .light : .medium).impactOccurred()
        } else if outcome == .incorrect {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        #endif
        if state.isGameOver { stop() }
    }

    private func connectTimer() {
        stop()
        timerCancellable = Timer.publish(every: 1.0 / 30, on: .main, in: .common)
            .autoconnect().sink { [weak self] _ in
                guard let self else { return }
                self.engine.update(now: self.now)
                self.state = self.engine.state
                if self.state.isGameOver { self.stop() }
            }
    }
}
