import SwiftUI
import TaapTaapCore

struct CreatePlayerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var playerName = ""
    @State private var selectedColor: TileColor = TileColor.presets[0]

    var onCreate: (String, TileColor) -> Void
    
    private var trimmedPlayerName: String {
        playerName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Player name", text: $playerName)

                Section("Tile color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))]) {
                        ForEach(TileColor.presets, id: \.self) { color in
                            Circle()
                                .fill(color.primaryColor)
                                .frame(width: 36, height: 36)
                                .overlay {
                                    Circle()
                                        .stroke(selectedColor == color ? Color.primary : .clear, lineWidth: 2)
                                }
                                .onTapGesture {
                                    selectedColor = color
                                }
                                .padding(4)
                        }
                    }
                }
            }
            .navigationTitle("New Player")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(trimmedPlayerName, selectedColor)
                        dismiss()
                    }
                    .disabled(trimmedPlayerName.isEmpty)
                }
            }
        }
    }
}
