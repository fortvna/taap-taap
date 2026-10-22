import SwiftUI
import TaapTaapCore

struct GameView: View {
    let player: PlayerProfile
    let mode: GameMode
    @ObservedObject var homeViewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.gameTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var viewModel: GameViewModel
    @State private var didPersistResult = false
    @State private var hitTile: Int?
    @State private var showHit = false
    private let keys = Array("1234qwerasdfzxcv5678tyui")

    init(player: PlayerProfile, mode: GameMode, homeViewModel: HomeViewModel) {
        self.player = player
        self.mode = mode
        self.homeViewModel = homeViewModel
        _viewModel = StateObject(wrappedValue: GameViewModel(mode: mode))
    }

    var body: some View {
        GeometryReader { geometry in
            let compact = geometry.size.width > geometry.size.height && geometry.size.height < 500
            let wide = geometry.size.width > 740 || compact
            let columns = compact ? viewModel.rows : viewModel.columns
            let maximumBoardWidth = boardWidth(in: geometry.size, columns: columns, compact: compact, wide: wide)
            ScrollView {
                VStack(spacing: compact ? 8 : 20) {
                    topBar
                    if wide {
                        HStack(alignment: .top, spacing: compact ? 16 : 28) {
                            playfield(columns: columns, compact: compact).frame(maxWidth: maximumBoardWidth)
                            dashboard(compact: compact).frame(width: 245)
                        }
                    } else {
                        scoreStrip
                        playfield(columns: columns, compact: false).frame(maxWidth: maximumBoardWidth)
                        statusStrip
                    }
                }
                .padding(compact ? 8 : 24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
            }
            .disabled(viewModel.state.isPaused || viewModel.state.isGameOver)
            .accessibilityHidden(viewModel.state.isPaused || viewModel.state.isGameOver)
            .overlay {
                if viewModel.state.isPaused { pauseOverlay }
                if viewModel.state.isGameOver { resultsOverlay }
            }
        }
        .background(ArcadeBackdrop())
        #if os(iOS)
        .navigationBarBackButtonHidden(true)
        #endif
        .onAppear { viewModel.startIfNeeded() }
        .onDisappear { viewModel.pause(); viewModel.stop() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { viewModel.pause() }
        }
        .onChange(of: viewModel.state.isGameOver) { _, ended in
            if ended { persistResultIfNeeded() }
        }
        .task(id: viewModel.state.feedbackID) {
            guard viewModel.state.feedbackID > 0, !reduceMotion else { return }
            showHit = true
            do { try await Task.sleep(for: .milliseconds(240)) } catch { return }
            withAnimation(.easeOut(duration: 0.18)) { showHit = false }
        }
    }

    private func boardWidth(in size: CGSize, columns: Int, compact: Bool, wide: Bool) -> CGFloat {
        let rows = viewModel.rows * viewModel.columns / columns
        let gap: CGFloat = compact ? 6 : 10
        let inset: CGFloat = compact ? 12 : 24
        let reservedHeight: CGFloat = compact ? 112 : (wide ? 210 : 310)
        let cellHeight = (size.height - reservedHeight - inset - CGFloat(rows - 1) * gap) / CGFloat(rows)
        let cellSize = max(compact ? 36 : 44, cellHeight)
        return min(540, CGFloat(columns) * cellSize + CGFloat(columns - 1) * gap + inset)
    }

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("TAAP / TAAP").font(.system(.headline, design: theme.fontDesign).weight(.black))
                HStack(spacing: 6) {
                    Circle().fill(player.tileColor.primaryColor).frame(width: 7, height: 7)
                    Text("\(player.name) · \(mode.title)").font(.caption).foregroundStyle(theme.muted)
                }
            }
            Spacer()
            if mode == .classic {
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < viewModel.state.livesRemaining ? "heart.fill" : "heart")
                            .font(.caption).foregroundStyle(index < viewModel.state.livesRemaining ? theme.danger : theme.muted.opacity(0.4))
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(viewModel.state.livesRemaining) lives")
            } else {
                Text(mode == .rush ? "\(Int(ceil(viewModel.state.timeRemaining ?? 0)))s" : "∞")
                    .font(.system(.title2, design: theme.fontDesign).bold()).monospacedDigit()
                    .foregroundStyle(theme.accent)
                    .accessibilityLabel(mode == .rush ? "\(Int(ceil(viewModel.state.timeRemaining ?? 0))) seconds left" : "Unlimited practice")
            }
            Button { viewModel.pause() } label: {
                Image(systemName: "pause.fill").frame(width: 44, height: 44)
                    .background(theme.panel, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain).keyboardShortcut(.space, modifiers: [])
            .accessibilityLabel("Pause game")
            .accessibilityIdentifier("game.pause")
        }
    }

    private var scoreStrip: some View {
        HStack(spacing: 16) {
            StatReadout(label: "Score", value: viewModel.state.score.formatted())
            StatReadout(label: "Combo", value: "×\(viewModel.state.multiplier)", color: theme.accent)
            StatReadout(label: "Level", value: String(format: "%02d", viewModel.state.level))
        }.arcadePanel()
    }

    private func playfield(columns: Int, compact: Bool) -> some View {
        VStack(spacing: compact ? 8 : 16) {
            HStack {
                Text(viewModel.state.slowdownRemaining > 0 ? "Slow motion" : "Follow the light")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(String(format: "%.2fs", viewModel.state.targetSecondsRemaining))
                    .font(.system(.subheadline, design: .monospaced).bold()).foregroundStyle(theme.accent)
                    .monospacedDigit().accessibilityHidden(true)
            }
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 3).fill(theme.ink.opacity(0.08))
                RoundedRectangle(cornerRadius: 3).fill(theme.accent)
                    .frame(width: geometry.size.width * viewModel.state.targetProgress)
            }.frame(height: 5).accessibilityHidden(true)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: compact ? 6 : 10), count: columns), spacing: compact ? 6 : 10) {
                ForEach(0..<(viewModel.rows * viewModel.columns), id: \.self) { index in
                    tile(index, columns: columns)
                }
            }
            .padding(compact ? 6 : 12)
            .background(theme.panel, in: RoundedRectangle(cornerRadius: theme.corner + 8))
            .overlay(RoundedRectangle(cornerRadius: theme.corner + 8).strokeBorder(theme.ink.opacity(0.09)))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Game board")
            .accessibilityIdentifier("game.board")
            if !compact { feedback }
        }
    }

    private func tile(_ index: Int, columns: Int) -> some View {
        let active = index == viewModel.state.activeTileIndex
        let power = active ? viewModel.state.powerUp : nil
        return Button {
            hitTile = index
            viewModel.tap(tileIndex: index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: theme.corner * 0.6)
                    .fill(active ? theme.target : theme.background)
                    .overlay {
                        RoundedRectangle(cornerRadius: theme.corner * 0.6)
                            .strokeBorder(active ? theme.targetInk.opacity(0.3) : theme.ink.opacity(0.08), lineWidth: active ? 2 : 1)
                    }
                    .shadow(color: active ? theme.target.opacity(theme == .cyber ? 0.6 : 0.3) : .clear, radius: active ? 14 : 0)
                if active {
                    Image(systemName: power?.symbol ?? "scope")
                        .font(.system(size: 26, weight: .bold)).foregroundStyle(theme.targetInk)
                    RoundedRectangle(cornerRadius: theme.corner * 0.6)
                        .trim(from: 0, to: viewModel.state.targetProgress)
                        .stroke(theme.targetInk.opacity(0.5), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .padding(5)
                }
                #if os(macOS)
                VStack {
                    Spacer()
                    HStack {
                        Text(String(keys[index]).uppercased()).font(.system(size: 10, weight: .medium, design: .monospaced))
                        Spacer()
                    }
                }.padding(9).foregroundStyle(active ? theme.targetInk.opacity(0.65) : theme.muted)
                #endif
                if showHit && hitTile == index && viewModel.state.lastPoints > 0 {
                    Image(systemName: theme == .sakura ? "sparkles" : "plus")
                        .font(.title).foregroundStyle(theme.accent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .contentShape(RoundedRectangle(cornerRadius: theme.corner * 0.6))
        }
        .buttonStyle(.plain)
        .keyboardShortcut(KeyEquivalent(keys[index]), modifiers: [])
        .accessibilityIdentifier("tile.\(index)")
        .accessibilityLabel("Row \(index / columns + 1), column \(index % columns + 1), \(active ? (power?.title ?? "bright target") : "unlit")")
        .accessibilityHint(active ? "Tap to score" : "Tapping an unlit square breaks your combo")
    }

    private var feedback: some View {
        HStack(spacing: 8) {
            if let reward = viewModel.state.lastReward { Image(systemName: reward.symbol) }
            Text(viewModel.state.feedback)
            if viewModel.state.lastPoints > 0 { Text("+\(viewModel.state.lastPoints)").monospacedDigit() }
        }
        .font(.system(.subheadline, design: theme.fontDesign).bold())
        .foregroundStyle(viewModel.state.lastPoints == 0 && viewModel.state.feedbackID > 0 ? theme.danger : theme.accent)
        .frame(minHeight: 24)
    }

    private var statusStrip: some View {
        VStack(spacing: 12) {
            HStack {
                Label("\(viewModel.state.streak) streak", systemImage: "flame.fill")
                Spacer()
                Text("\(viewModel.state.tapCount) taps")
            }.font(.caption.bold()).foregroundStyle(theme.muted)
            HStack {
                if viewModel.state.slowdownRemaining > 0 {
                    Label(String(format: "Slow · %.1fs", viewModel.state.slowdownRemaining), systemImage: "hourglass")
                }
                if viewModel.state.hasShield { Label("Shield ready", systemImage: "shield.fill") }
                if viewModel.state.slowdownRemaining <= 0 && !viewModel.state.hasShield {
                    Text("Boost in \(8 - viewModel.state.tapCount % 8) taps")
                }
            }.font(.caption.bold()).foregroundStyle(theme.accent)
        }
    }

    private func dashboard(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: compact ? 12 : 20) {
            scoreStrip
            statusStrip.arcadePanel()
            if compact {
                feedback
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Catch a boost").font(.headline)
                    if mode == .classic { boostHelp("heart.fill", "Extra life", "Adds one heart, up to five.") }
                    boostHelp("hourglass", "Slow motion", "Half speed for five seconds.")
                    boostHelp("shield.fill", "Shield", "Absorbs the next penalty.")
                    Text("A collectible appears after every 8 hits. Tap it before it disappears.")
                        .font(.caption).foregroundStyle(theme.muted)
                }.arcadePanel()
            }
            #if os(macOS)
            Text("Keys: 1234 / QWER / ASDF / ZXCV / 5678 / TYUI\nSpace to pause or resume")
                .font(.caption).foregroundStyle(theme.muted)
            #endif
        }
    }

    private func boostHelp(_ symbol: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol).foregroundStyle(theme.accent).frame(width: 22)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.bold())
                Text(detail).font(.caption).foregroundStyle(theme.muted)
            }
        }
    }

    private var pauseOverlay: some View {
        overlaySurface {
            Image(systemName: "pause.circle").font(.system(size: 44)).foregroundStyle(theme.accent)
            Text("Take a breath.").font(.system(.largeTitle, design: theme.fontDesign).bold())
            Text("Your timers are paused.").foregroundStyle(theme.muted)
            Button("Resume") { viewModel.resume() }
                .buttonStyle(ArcadeButtonStyle()).keyboardShortcut(.space, modifiers: [])
                .accessibilityIdentifier("game.resume")
            if mode == .zen {
                Button("Finish practice & save") { viewModel.finish() }.buttonStyle(.bordered)
            }
            Button("Leave game") { dismiss() }.buttonStyle(.plain).foregroundStyle(theme.muted)
                .accessibilityIdentifier("game.leave")
        }
    }

    private var resultsOverlay: some View {
        overlaySurface {
            Image(systemName: "trophy.fill").font(.system(size: 40)).foregroundStyle(theme.accent)
            Text(mode == .zen ? "Good practice." : "What a run.")
                .font(.system(.largeTitle, design: theme.fontDesign).bold())
            Text(viewModel.state.score.formatted())
                .font(.system(size: 60, weight: .black, design: theme.fontDesign)).minimumScaleFactor(0.5)
            Text("\(mode.title) · Final score").font(.caption).foregroundStyle(theme.muted)
            HStack {
                StatReadout(label: "Best streak", value: "\(viewModel.state.bestStreak)")
                StatReadout(label: "Accuracy", value: "\(Int(viewModel.state.accuracy * 100))%")
                StatReadout(label: "Taps", value: "\(viewModel.state.tapCount)")
            }.padding(.vertical, 8)
            Button("Play again") {
                didPersistResult = false
                hitTile = nil
                homeViewModel.markGameStarted(for: player)
                viewModel.start()
            }.buttonStyle(ArcadeButtonStyle())
            Button("Back to arcade") { dismiss() }.buttonStyle(.plain).foregroundStyle(theme.muted)
        }
    }

    private func overlaySurface<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            theme.background.opacity(0.96).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18, content: content)
                    .arcadePanel().frame(maxWidth: 430).padding(24).frame(maxWidth: .infinity)
            }.defaultScrollAnchor(.center)
        }
    }

    private func persistResultIfNeeded() {
        guard !didPersistResult else { return }
        didPersistResult = true
        homeViewModel.saveResult(for: player, tapCount: viewModel.state.tapCount,
                                 maxMultiplier: viewModel.state.maxMultiplier, score: viewModel.state.score,
                                 mode: mode, bestStreak: viewModel.state.bestStreak, accuracy: viewModel.state.accuracy)
    }
}
