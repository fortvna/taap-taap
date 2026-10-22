import SwiftUI
import TaapTaapCore

struct HomeView: View {
    @Environment(\.gameTheme) private var theme
    @AppStorage("taap.theme") private var selectedTheme: GameTheme = .studio
    @ObservedObject var viewModel: HomeViewModel
    var onStartGame: (PlayerProfile, GameMode) -> Void
    @State private var isShowingCreatePlayer = false
    @State private var selectedPlayerID: UUID?
    @State private var mode: GameMode = .classic

    private var player: PlayerProfile? {
        viewModel.players.first { $0.id == selectedPlayerID } ?? viewModel.players.first
    }
    private var entries: [LeaderboardEntry] {
        viewModel.leaderboard.filter { ($0.mode ?? .classic) == mode }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    masthead
                    themeSelector
                    if geometry.size.width > 780 {
                        HStack(alignment: .top, spacing: 32) {
                            hero.frame(maxWidth: .infinity)
                            launchPanel.frame(width: 370)
                        }
                    } else {
                        compactHero
                        launchPanel
                        demoBoard.frame(maxWidth: 480).frame(maxWidth: .infinity)
                    }
                    HStack(alignment: .firstTextBaseline) {
                        Label("LOCAL LEGENDS", systemImage: "trophy.fill")
                            .font(.system(.caption, design: .monospaced).bold()).tracking(2)
                        Spacer()
                        Text(mode.title).foregroundStyle(theme.muted).font(.caption)
                    }
                    VStack(spacing: 16) { LeaderboardView(entries: entries) }.arcadePanel()
                    Text("ONE LIGHT. ONE TAP. ONE MORE TRY.")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .tracking(2).foregroundStyle(theme.muted)
                        .frame(maxWidth: .infinity)
                }
                .padding(24).frame(maxWidth: 1120).frame(maxWidth: .infinity)
            }
        }
        .background(ArcadeBackdrop())
        .sheet(isPresented: $isShowingCreatePlayer) {
            CreatePlayerView { name, color in
                selectedPlayerID = viewModel.createPlayer(name: name, tileColor: color).id
            }
        }
    }

    private var themeSelector: some View {
        HStack(spacing: 10) {
            ForEach(GameTheme.allCases) { candidate in
                Button { selectedTheme = candidate } label: {
                    VStack(spacing: 6) {
                        Image(systemName: candidate.symbol).font(.title3)
                        Text(candidate.title).font(.subheadline.bold())
                        Text(candidate.subtitle).font(.caption2).lineLimit(1).minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                    .foregroundStyle(candidate == theme ? theme.accent : theme.muted)
                    .background(theme.panel, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(candidate == theme ? theme.accent : .clear, lineWidth: 2))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("theme.\(candidate.rawValue)")
                .accessibilityLabel("\(candidate.title) theme, \(candidate.subtitle)")
                .accessibilityAddTraits(candidate == theme ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Visual theme")
    }

    private var masthead: some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: "square.grid.2x2.fill").foregroundStyle(theme.accent)
                Text("TAAP / TAAP").font(.system(.headline, design: theme.fontDesign).weight(.black)).tracking(2)
            }
            Spacer()
            Text("REACTION ARCADE")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(1).foregroundStyle(theme.muted)
        }
    }

    private var compactHero: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Chase the light.")
                    .font(.system(.largeTitle, design: theme.fontDesign).weight(.black))
                Text("Tap. Build a streak. Beat your best.")
                    .font(.subheadline).foregroundStyle(theme.muted)
            }
            Spacer(minLength: 0)
            ThemeEmblem().frame(width: 72, height: 72).clipped()
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label("GET INTO THE FLOW", systemImage: "waveform.path")
                .font(.system(.caption, design: .monospaced).bold()).tracking(2)
                .foregroundStyle(theme.accent)
            Text("Chase\nthe light.")
                .font(.system(size: 64, weight: .black, design: theme.fontDesign))
                .tracking(-3).lineSpacing(-8).minimumScaleFactor(0.6)
                .accessibilityLabel("Chase the light")
            Text("A little focus. A faster heartbeat.\nTap the glowing square and keep the streak alive.")
                .font(.callout).foregroundStyle(theme.muted).lineSpacing(5)
            ThemeEmblem()
            demoBoard
            HStack(spacing: 16) {
                Label("5s start", systemImage: "timer")
                Label("8× combos", systemImage: "bolt.fill")
                Label("Power-ups", systemImage: "sparkles")
            }
            .font(.system(size: 11, weight: .semibold)).foregroundStyle(theme.muted)
        }
    }

    private var demoBoard: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
            ForEach(0..<24) { index in
                RoundedRectangle(cornerRadius: 12)
                    .fill(index == 6 ? theme.target : theme.background)
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(theme.ink.opacity(index == 6 ? 0.7 : 0.06)))
                    .overlay {
                        if index == 6 {
                            Image(systemName: "bolt.fill").font(.title2).foregroundStyle(theme.targetInk)
                        }
                    }
                    .shadow(color: index == 6 ? theme.accent.opacity(0.45) : .clear, radius: 20)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .padding(18).arcadePanel()
        .accessibilityHidden(true)
    }

    private var launchPanel: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("YOUR NEXT HIGH SCORE")
                .font(.system(.caption, design: .monospaced).bold()).tracking(1.5)
                .foregroundStyle(theme.muted)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(player?.name ?? "Ready, player one?")
                        .font(.system(.title2, design: theme.fontDesign).bold())
                    Text(player.map { "\($0.gamesPlayed) games played" } ?? "Create a profile to keep your scores.")
                        .font(.caption).foregroundStyle(theme.muted)
                }
                Spacer()
                Button { isShowingCreatePlayer = true } label: {
                    Image(systemName: "person.badge.plus").padding(12)
                }
                .buttonStyle(.plain).foregroundStyle(theme.accent)
                .accessibilityLabel("Create player")
                .accessibilityIdentifier("player.add")
            }
            if viewModel.players.count > 1 {
                Picker("Player", selection: Binding(get: { player?.id }, set: { selectedPlayerID = $0 })) {
                    ForEach(viewModel.players) { player in
                        Text(player.name).tag(Optional(player.id))
                    }
                }
            }
            VStack(spacing: 10) {
                ForEach(GameMode.allCases) { candidate in
                    Button { mode = candidate } label: {
                        HStack(spacing: 14) {
                            Image(systemName: candidate.symbol).font(.title3)
                                .foregroundStyle(mode == candidate ? theme.accent : theme.muted)
                                .frame(width: 26)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(candidate.title).font(.headline).foregroundStyle(theme.ink)
                                Text(candidate.subtitle).font(.caption).foregroundStyle(theme.muted)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: mode == candidate ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(mode == candidate ? theme.accent : theme.muted)
                        }
                        .padding(15)
                        .background(mode == candidate ? theme.accent.opacity(0.07) : theme.background.opacity(0.5),
                                    in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(mode == candidate ? theme.accent.opacity(0.55) : theme.ink.opacity(0.06)))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("mode.\(candidate.rawValue)")
                    .accessibilityAddTraits(mode == candidate ? .isSelected : [])
                }
            }
            Button {
                if let player { onStartGame(player, mode) }
                else { isShowingCreatePlayer = true }
            } label: {
                HStack {
                    Text(player == nil ? "Create your player" : "Let's play")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
            }.buttonStyle(ArcadeButtonStyle())
            .accessibilityIdentifier("game.start")
            Text("Tap the bright square before its light runs out. Every bounce gets faster. Collect glowing items for a boost.")
                .font(.caption).foregroundStyle(theme.muted).lineSpacing(4)
        }
        .arcadePanel()
    }
}
