import SwiftUI
import TaapTaapCore

struct LeaderboardView: View {
    @Environment(\.gameTheme) private var theme
    let entries: [LeaderboardEntry]

    var body: some View {
        if entries.isEmpty {
            HStack(spacing: 16) {
                Image(systemName: "flag.checkered").font(.title2).foregroundStyle(theme.accent)
                VStack(alignment: .leading, spacing: 5) {
                    Text("The top spot is open.").font(.headline)
                    Text("Finish a run to put your name on the board.").font(.caption).foregroundStyle(theme.muted)
                }
                Spacer()
            }
        } else {
            ForEach(Array(entries.prefix(10).enumerated()), id: \.element.id) { index, entry in
                HStack(spacing: 14) {
                    Text(String(format: "%02d", index + 1))
                        .font(.system(.headline, design: .monospaced)).foregroundStyle(index == 0 ? theme.accent : theme.muted)
                        .frame(width: 32, alignment: .leading)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(entry.playerName).font(.headline)
                        Text("\(entry.tapCount) taps · ×\(entry.maxMultiplier) best\(entry.mode == nil ? " · Legacy" : "")")
                            .font(.caption).foregroundStyle(theme.muted)
                    }
                    Spacer()
                    Text(entry.score.formatted()).font(.system(.title3, design: theme.fontDesign).bold())
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}
