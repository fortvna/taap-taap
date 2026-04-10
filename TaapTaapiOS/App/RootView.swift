import SwiftUI
import TaapTaapCore

struct RootView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var activePlayer: PlayerProfile?

    var body: some View {
        NavigationStack {
            HomeView(viewModel: homeViewModel) { player in
                activePlayer = player
            }
            .navigationDestination(item: $activePlayer) { player in
                GameView(
                    player: player,
                    homeViewModel: homeViewModel
                )
            }
            .navigationTitle("Taap Taap")
        }
    }
}
