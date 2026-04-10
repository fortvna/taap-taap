import SwiftUI
import TaapTaapCore

struct LeaderboardView: View {
    let entries: [LeaderboardEntry]

    var body: some View {
        if entries.isEmpty {
            Text("No games played yet.")
                .foregroundStyle(.secondary)
        } else {
            ForEach(Array(entries.prefix(10).enumerated()), id: \.element.id) { index, entry in
                HStack {
                    Text("#\(index + 1)")
                        .frame(width: 34, alignment: .leading)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.playerName)
                        Text("Taps: \(entry.tapCount) • Max x\(entry.maxMultiplier)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(entry.score)")
                        .font(.headline)
                }
                .padding(.vertical, 2)
            }
        }
    }
}
