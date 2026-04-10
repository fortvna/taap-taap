import Foundation

public final class LeaderboardStore: @unchecked Sendable {
    private enum Keys {
        static let entries = "taap.leaderboard.entries"
    }

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    public func loadEntries(limit: Int? = nil) -> [LeaderboardEntry] {
        guard let data = defaults.data(forKey: Keys.entries) else {
            return []
        }

        let entries = (try? decoder.decode([LeaderboardEntry].self, from: data)) ?? []
        let sorted = entries.sorted {
            if $0.score == $1.score {
                return $0.playedAt > $1.playedAt
            }
            return $0.score > $1.score
        }

        guard let limit else { return sorted }
        return Array(sorted.prefix(limit))
    }

    public func addEntry(_ entry: LeaderboardEntry) {
        var entries = loadEntries(limit: nil)
        entries.append(entry)
        guard let data = try? encoder.encode(entries) else { return }
        defaults.set(data, forKey: Keys.entries)
    }
}
