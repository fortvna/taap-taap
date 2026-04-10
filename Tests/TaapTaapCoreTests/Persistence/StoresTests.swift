import Foundation
import Testing
@testable import TaapTaapCore

struct StoresTests {
    @Test
    func playerStoreCanCreateAndSelectPlayer() {
        let suiteName = "player-store-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let store = PlayerProfileStore(defaults: defaults)
        let player = store.createPlayer(name: "Amir", tileColor: .presets[0])

        let players = store.loadPlayers()

        #expect(players.count == 1)
        #expect(players.first?.name == "Amir")
        #expect(store.selectedPlayerID() == player.id)
    }

    @Test
    func leaderboardSortsByScoreDescending() {
        let suiteName = "leaderboard-store-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let store = LeaderboardStore(defaults: defaults)
        let playerID = UUID()

        store.addEntry(.init(playerID: playerID, playerName: "A", score: 12, tapCount: 4, maxMultiplier: 3))
        store.addEntry(.init(playerID: playerID, playerName: "B", score: 20, tapCount: 5, maxMultiplier: 4))

        let entries = store.loadEntries()

        #expect(entries.first?.score == 20)
        #expect(entries.last?.score == 12)
    }
}
