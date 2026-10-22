import Foundation
import Testing
@testable import TaapTaapCore

struct CompatibilityTests {
    @Test func existingLeaderboardDataStillDecodes() throws {
        let legacy = """
        [{"id":"00000000-0000-0000-0000-000000000001",
          "playerID":"00000000-0000-0000-0000-000000000002",
          "playerName":"Original player","score":42,"tapCount":7,
          "maxMultiplier":6,"playedAt":100}]
        """
        let entries = try JSONDecoder().decode([LeaderboardEntry].self, from: Data(legacy.utf8))
        #expect(entries.count == 1)
        #expect(entries[0].score == 42)
        #expect(entries[0].mode == nil)
        #expect(entries[0].bestStreak == nil)
    }

    @Test func newModeAndRunStatisticsSurviveRoundTrip() throws {
        let entry = LeaderboardEntry(playerID: UUID(), playerName: "Rush player", score: 12_000,
                                     tapCount: 40, maxMultiplier: 8, mode: .rush, bestStreak: 35, accuracy: 0.95)
        let restored = try JSONDecoder().decode(LeaderboardEntry.self, from: JSONEncoder().encode(entry))
        #expect(restored == entry)
        #expect(restored.mode == .rush)
        #expect(restored.bestStreak == 35)
        #expect(restored.accuracy == 0.95)
    }
}
