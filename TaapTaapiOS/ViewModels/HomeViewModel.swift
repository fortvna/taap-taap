import Combine
import Foundation
import TaapTaapCore

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var players: [PlayerProfile] = []
    @Published private(set) var leaderboard: [LeaderboardEntry] = []

    private let playerStore: PlayerProfileStore
    private let leaderboardStore: LeaderboardStore

    init(
        playerStore: PlayerProfileStore = .init(),
        leaderboardStore: LeaderboardStore = .init()
    ) {
        self.playerStore = playerStore
        self.leaderboardStore = leaderboardStore
        refresh()
    }

    func refresh() {
        players = playerStore.loadPlayers()
        leaderboard = leaderboardStore.loadEntries()
    }

    @discardableResult
    func createPlayer(name: String, tileColor: TileColor) -> PlayerProfile {
        let profile = playerStore.createPlayer(
            name: name,
            tileColor: tileColor
        )
        refresh()
        return profile
    }

    func markGameStarted(for player: PlayerProfile) {
        playerStore.incrementGamesPlayed(for: player.id)
        refresh()
    }

    func saveResult(for player: PlayerProfile, tapCount: Int, maxMultiplier: Int, score: Int, mode: GameMode, bestStreak: Int, accuracy: Double) {
        let entry = LeaderboardEntry(
            playerID: player.id,
            playerName: player.name,
            score: score,
            tapCount: tapCount,
            maxMultiplier: maxMultiplier,
            mode: mode,
            bestStreak: bestStreak,
            accuracy: accuracy
        )
        leaderboardStore.addEntry(entry)
        refresh()
    }
}
