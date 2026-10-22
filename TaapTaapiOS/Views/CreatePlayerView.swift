import SwiftUI
import TaapTaapCore

struct CreatePlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.gameTheme) private var theme
    @State private var playerName = ""
    @State private var selectedColor: TileColor = TileColor.presets[0]
    var onCreate: (String, TileColor) -> Void
    private var trimmedPlayerName: String { playerName.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Meet your next best.").font(.system(.title, design: theme.fontDesign).bold())
                Spacer()
                Button { dismiss() } label: { Image(systemName: "xmark.circle.fill") }
                    .buttonStyle(.plain).accessibilityLabel("Cancel")
            }
            Text("Your name, your color, your high scores.").foregroundStyle(theme.muted)
            TextField("Player name", text: $playerName).textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("player.name")
                .onSubmit(create)
                .onChange(of: playerName) { _, value in
                    if value.count > 24 { playerName = String(value.prefix(24)) }
                }
            Text("Player color").font(.headline)
            HStack(spacing: 8) {
                ForEach(Array(TileColor.presets.enumerated()), id: \.offset) { index, color in
                    Button { selectedColor = color } label: {
                        Circle().fill(color.primaryColor).frame(width: 36, height: 36)
                            .overlay {
                                if selectedColor == color {
                                    Image(systemName: "checkmark").font(.headline.bold()).foregroundStyle(.white)
                                }
                            }
                            .padding(4)
                            .overlay(Circle().strokeBorder(selectedColor == color ? theme.ink : .clear, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(["Purple", "Blue", "Green", "Red", "Orange"][index])
                    .accessibilityAddTraits(selectedColor == color ? .isSelected : [])
                }
            }
            Button("Create player", action: create).buttonStyle(ArcadeButtonStyle())
                .accessibilityIdentifier("player.create")
                .disabled(trimmedPlayerName.isEmpty).opacity(trimmedPlayerName.isEmpty ? 0.5 : 1)
        }
        .padding(28).frame(idealWidth: 450).background(theme.background)
        .foregroundStyle(theme.ink).preferredColorScheme(theme.colorScheme)
        .presentationDetents([.medium, .large])
    }
    private func create() {
        guard !trimmedPlayerName.isEmpty else { return }
        onCreate(trimmedPlayerName, selectedColor)
        dismiss()
    }
}
