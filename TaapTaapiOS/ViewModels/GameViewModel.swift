import Combine
import Foundation
import TaapTaapCore

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState

    private let engine: GameEngine
    private var timerCancellable: AnyCancellable?

    var rows: Int { engine.configuration.rows }
    var columns: Int { engine.configuration.columns }

    init(engine: GameEngine = .init()) {
        self.engine = engine
        self.state = engine.state
    }

    func start() {
        engine.start(now: .now)
        state = engine.state

        timerCancellable = Timer
            .publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                self?.tick(now: now)
            }
    }

    func stop() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func tap(tileIndex: Int) {
        _ = engine.handleTap(on: tileIndex, now: .now)
        state = engine.state
    }

    private func tick(now: Date) {
        guard !state.isGameOver else {
            stop()
            return
        }

        engine.update(now: now)
        state = engine.state

        if state.isGameOver {
            stop()
        }
    }
}
