import Foundation

public struct TileColor: Codable, Hashable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public static let presets: [TileColor] = [
        .init(red: 0.40, green: 0.18, blue: 0.88),
        .init(red: 0.18, green: 0.43, blue: 0.90),
        .init(red: 0.19, green: 0.65, blue: 0.56),
        .init(red: 0.94, green: 0.37, blue: 0.36),
        .init(red: 0.97, green: 0.64, blue: 0.19)
    ]
}
