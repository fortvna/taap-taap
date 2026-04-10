import SwiftUI
import TaapTaapCore

struct GameView: View {
    let player: PlayerProfile
    @ObservedObject var homeViewModel: HomeViewModel

    @StateObject private var viewModel = GameViewModel()
    @State private var didPersistResult = false

    var body: some View {
        VStack(spacing: 16) {
            header
            tileGrid
            if viewModel.state.isGameOver {
                gameOverCard
            }
        }
        .padding()
        .navigationTitle(player.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
        .onChange(of: viewModel.state.isGameOver) { _, isGameOver in
            if isGameOver {
                persistResultIfNeeded()
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Taps: \(viewModel.state.tapCount)")
                Text("Multiplier: x\(viewModel.state.maxMultiplier)")
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("Score: \(viewModel.state.score)")
                Text("Lives: \(viewModel.state.livesRemaining)")
            }
        }
        .font(.headline)
    }

    private var tileGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: viewModel.columns)

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0 ..< viewModel.rows * viewModel.columns, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8)
                    .fill(tileColor(for: index))
                    .frame(height: 64)
                    .onTapGesture {
                        viewModel.tap(tileIndex: index)
                    }
            }
        }
        .animation(.easeInOut(duration: 0.12), value: viewModel.state.activeTileIndex)
    }

    private var gameOverCard: some View {
        VStack(spacing: 12) {
            Text("Game Over")
                .font(.title2.bold())
            Text("Final score: \(viewModel.state.score)")
            Button("Play Again") {
                didPersistResult = false
                viewModel.start()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func tileColor(for index: Int) -> Color {
        if index == viewModel.state.activeTileIndex {
            return player.tileColor.primaryColor
        }
        return player.tileColor.primaryColor.opacity(0.28)
    }

    private func persistResultIfNeeded() {
        guard !didPersistResult else { return }
        didPersistResult = true

        homeViewModel.saveResult(
            for: player,
            tapCount: viewModel.state.tapCount,
            maxMultiplier: viewModel.state.maxMultiplier,
            score: viewModel.state.score
        )
    }
}
