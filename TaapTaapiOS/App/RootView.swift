import SwiftUI
import TaapTaapCore

private struct GameSession: Hashable {
    let id = UUID()
    let player: PlayerProfile
    let mode: GameMode
}

struct RootView: View {
    @AppStorage("taap.theme") private var theme: GameTheme = .studio
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var session: GameSession?

    var body: some View {
        NavigationStack {
            HomeView(viewModel: homeViewModel) { player, mode in
                homeViewModel.markGameStarted(for: player)
                session = GameSession(player: player, mode: mode)
            }
            .navigationDestination(item: $session) { session in
                GameView(player: session.player, mode: session.mode, homeViewModel: homeViewModel)
            }
        }
        .environment(\.gameTheme, theme)
        .tint(theme.accent)
        .foregroundStyle(theme.ink)
        .preferredColorScheme(theme.colorScheme)
    }
}
