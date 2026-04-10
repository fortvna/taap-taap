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
        leaderboard = leaderboardStore.loadEntries(limit: 25)
    }

    @discardableResult
    func createPlayer(name: String, tileColor: TileColor) -> PlayerProfile {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let profile = playerStore.createPlayer(
            name: cleanName.isEmpty ? "Player" : cleanName,
            tileColor: tileColor
        )
        refresh()
        return profile
    }

    func markGameStarted(for player: PlayerProfile) {
        playerStore.incrementGamesPlayed(for: player.id)
        refresh()
    }

    func saveResult(for player: PlayerProfile, tapCount: Int, maxMultiplier: Int, score: Int) {
        let entry = LeaderboardEntry(
            playerID: player.id,
            playerName: player.name,
            score: score,
            tapCount: tapCount,
            maxMultiplier: maxMultiplier
        )
        leaderboardStore.addEntry(entry)
        refresh()
    }
}
