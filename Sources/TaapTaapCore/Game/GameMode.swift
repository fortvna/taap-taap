import Foundation

public enum GameMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case classic, rush, zen

    public var id: String { rawValue }
    public var title: String { rawValue.capitalized }
    public var subtitle: String {
        switch self {
        case .classic: "Three lives. Chase your best."
        case .rush: "60 seconds. Make every tap count."
        case .zen: "Find your rhythm. No lives to lose."
        }
    }
    public var symbol: String {
        switch self {
        case .classic: "bolt.fill"
        case .rush: "timer"
        case .zen: "sparkles"
        }
    }
}

public enum PowerUp: String, CaseIterable, Codable, Sendable {
    case extraLife, slowdown, shield

    public var title: String {
        switch self {
        case .extraLife: "Extra life"
        case .slowdown: "Slow motion"
        case .shield: "Shield"
        }
    }
    public var symbol: String {
        switch self {
        case .extraLife: "heart.fill"
        case .slowdown: "hourglass"
        case .shield: "shield.fill"
        }
    }
}
