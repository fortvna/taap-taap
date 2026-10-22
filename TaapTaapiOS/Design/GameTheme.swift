import SwiftUI

enum GameTheme: String, CaseIterable, Identifiable {
    case studio, sakura, cyber
    var id: String { rawValue }
    var title: String {
        switch self { case .studio: "Studio"; case .sakura: "Sakura"; case .cyber: "Cyber" }
    }
    var subtitle: String {
        switch self {
        case .studio: "Clean & focused"
        case .sakura: "Anime arcade"
        case .cyber: "Neon overdrive"
        }
    }
    var symbol: String {
        switch self { case .studio: "circle.lefthalf.filled"; case .sakura: "leaf.fill"; case .cyber: "bolt.horizontal.fill" }
    }
    var background: Color {
        switch self {
        case .studio: Color(hex: 0xEEF2F8)
        case .sakura: Color(hex: 0xFFF0F4)
        case .cyber: Color(hex: 0x080C20)
        }
    }
    var panel: Color {
        switch self { case .studio: .white; case .sakura: Color(hex: 0xFFFAF6); case .cyber: Color(hex: 0x12182E) }
    }
    var ink: Color {
        switch self { case .studio: Color(hex: 0x162440); case .sakura: Color(hex: 0x32233E); case .cyber: Color(hex: 0xEDF8FF) }
    }
    var muted: Color {
        switch self { case .studio: Color(hex: 0x56647C); case .sakura: Color(hex: 0x79566E); case .cyber: Color(hex: 0x9CAEC8) }
    }
    var accent: Color {
        switch self { case .studio: Color(hex: 0x225DE5); case .sakura: Color(hex: 0xB82664); case .cyber: Color(hex: 0x67F8ED) }
    }
    var secondary: Color {
        switch self { case .studio: Color(hex: 0x73A6F9); case .sakura: Color(hex: 0xFA9CB8); case .cyber: Color(hex: 0xF15BDE) }
    }
    var target: Color {
        switch self { case .studio: Color(hex: 0x68C8FF); case .sakura: Color(hex: 0xFF9CBD); case .cyber: accent }
    }
    var targetInk: Color { Color(hex: 0x17233B) }
    var buttonInk: Color { self == .cyber ? background : .white }
    var danger: Color { self == .cyber ? Color(hex: 0xFF7DA2) : Color(hex: 0xB1234B) }
    var corner: CGFloat { self == .cyber ? 8 : (self == .sakura ? 14 : 22) }
    var fontDesign: Font.Design { self == .cyber ? .monospaced : .rounded }
    var colorScheme: ColorScheme { self == .cyber ? .dark : .light }
}

private struct GameThemeKey: EnvironmentKey {
    static let defaultValue = GameTheme.studio
}
extension EnvironmentValues {
    var gameTheme: GameTheme {
        get { self[GameThemeKey.self] }
        set { self[GameThemeKey.self] = newValue }
    }
}

private extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 255) / 255,
                  green: Double((hex >> 8) & 255) / 255,
                  blue: Double(hex & 255) / 255)
    }
}
