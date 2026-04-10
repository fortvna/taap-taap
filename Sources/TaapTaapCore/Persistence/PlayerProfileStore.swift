import Foundation

public final class PlayerProfileStore: @unchecked Sendable {
    private enum Keys {
        static let players = "taap.players"
        static let selectedPlayerID = "taap.selectedPlayerID"
    }

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    public func loadPlayers() -> [PlayerProfile] {
        guard let data = defaults.data(forKey: Keys.players) else {
            return []
        }

        return (try? decoder.decode([PlayerProfile].self, from: data))?
            .sorted(by: { $0.createdAt < $1.createdAt }) ?? []
    }

    public func save(players: [PlayerProfile]) {
        guard let data = try? encoder.encode(players) else { return }
        defaults.set(data, forKey: Keys.players)
    }

    @discardableResult
    public func createPlayer(name: String, tileColor: TileColor) -> PlayerProfile {
        var players = loadPlayers()
        let profile = PlayerProfile(name: name, tileColor: tileColor)
        players.append(profile)
        save(players: players)
        selectPlayer(id: profile.id)
        return profile
    }

    public func updatePlayer(_ profile: PlayerProfile) {
        var players = loadPlayers()
        guard let index = players.firstIndex(where: { $0.id == profile.id }) else { return }
        players[index] = profile
        save(players: players)
    }

    public func incrementGamesPlayed(for playerID: UUID) {
        var players = loadPlayers()
        guard let index = players.firstIndex(where: { $0.id == playerID }) else { return }
        players[index].gamesPlayed += 1
        save(players: players)
    }

    public func selectPlayer(id: UUID) {
        defaults.set(id.uuidString, forKey: Keys.selectedPlayerID)
    }

    public func selectedPlayerID() -> UUID? {
        guard let rawValue = defaults.string(forKey: Keys.selectedPlayerID) else { return nil }
        return UUID(uuidString: rawValue)
    }
}
