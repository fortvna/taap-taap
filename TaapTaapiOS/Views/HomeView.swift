import SwiftUI
import TaapTaapCore

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    var onStartGame: (PlayerProfile) -> Void

    @State private var isShowingCreatePlayer = false

    var body: some View {
        List {
            Section("Players") {
                if viewModel.players.isEmpty {
                    Text("Create your first profile to start playing.")
                        .foregroundStyle(.secondary)
                }

                ForEach(viewModel.players) { player in
                    HStack {
                        Circle()
                            .fill(player.tileColor.primaryColor)
                            .frame(width: 18, height: 18)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(player.name)
                            Text("Games played: \(player.gamesPlayed)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button("Play") {
                            viewModel.markGameStarted(for: player)
                            onStartGame(player)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section {
                Button {
                    isShowingCreatePlayer = true
                } label: {
                    Label("Create Player", systemImage: "plus.circle.fill")
                }
            }

            Section("Leaderboard") {
                LeaderboardView(entries: viewModel.leaderboard)
            }
        }
        .sheet(isPresented: $isShowingCreatePlayer) {
            CreatePlayerView { name, color in
                _ = viewModel.createPlayer(name: name, tileColor: color)
            }
        }
    }
}
