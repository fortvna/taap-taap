import SwiftUI

struct ArcadeBackdrop: View {
    @Environment(\.gameTheme) private var theme
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                theme.background
                if theme == .studio {
                    Circle().fill(theme.secondary.opacity(0.15)).frame(width: 500)
                        .offset(x: geometry.size.width * 0.35, y: -240)
                } else if theme == .sakura {
                    Circle().fill(theme.secondary.opacity(0.22)).frame(width: 320)
                        .offset(x: geometry.size.width * 0.3, y: -200)
                    Canvas { context, size in
                        for index in 0..<24 {
                            let x = CGFloat((index * 73 + 13) % 100) / 100 * size.width
                            let y = CGFloat((index * 41 + 9) % 100) / 100 * size.height
                            var petal = context
                            petal.translateBy(x: x, y: y)
                            petal.rotate(by: .degrees(Double(index * 29)))
                            petal.fill(Path(ellipseIn: CGRect(x: 0, y: 0, width: 7, height: 15)),
                                       with: .color(theme.secondary.opacity(0.3)))
                        }
                    }
                } else {
                    RadialGradient(colors: [theme.secondary.opacity(0.15), .clear], center: .top,
                                   startRadius: 0, endRadius: geometry.size.width * 0.8)
                    Canvas { context, size in
                        let horizon = size.height * 0.6
                        var grid = Path()
                        for i in -8...8 {
                            grid.move(to: CGPoint(x: size.width / 2 + CGFloat(i) * 15, y: horizon))
                            grid.addLine(to: CGPoint(x: size.width / 2 + CGFloat(i) * 140, y: size.height))
                        }
                        for i in 0..<12 {
                            let fraction = pow(Double(i) / 11, 2)
                            let y = horizon + (size.height - horizon) * fraction
                            grid.move(to: CGPoint(x: 0, y: y))
                            grid.addLine(to: CGPoint(x: size.width, y: y))
                        }
                        context.stroke(grid, with: .color(theme.accent.opacity(0.12)), lineWidth: 1)
                    }
                }
            }
        }
        .ignoresSafeArea().accessibilityHidden(true)
    }
}

struct ArcadePanel: ViewModifier {
    @Environment(\.gameTheme) private var theme
    func body(content: Content) -> some View {
        content.padding(20)
            .background(theme.panel.opacity(0.97), in: RoundedRectangle(cornerRadius: theme.corner))
            .overlay(RoundedRectangle(cornerRadius: theme.corner)
                .strokeBorder(theme.ink.opacity(theme == .sakura ? 0.5 : 0.08), lineWidth: theme == .sakura ? 1.5 : 1))
            .shadow(color: theme.ink.opacity(theme == .studio ? 0.05 : 0), radius: 18, y: 8)
    }
}
extension View {
    func arcadePanel() -> some View { modifier(ArcadePanel()) }
}

struct ArcadeButtonStyle: ButtonStyle {
    @Environment(\.gameTheme) private var theme
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: theme.fontDesign).weight(.bold))
            .foregroundStyle(theme.buttonInk)
            .padding(.horizontal, 24).padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(theme.accent, in: RoundedRectangle(cornerRadius: theme.corner * 0.7))
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

struct StatReadout: View {
    @Environment(\.gameTheme) private var theme
    let label: String
    let value: String
    var color: Color? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.caption.weight(.semibold)).foregroundStyle(theme.muted)
            Text(value).font(.system(.title2, design: theme.fontDesign).weight(.heavy))
                .monospacedDigit().foregroundStyle(color ?? theme.ink)
                .lineLimit(1).minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// Original vector emblem: a quiet studio mark, manga sunburst, or neon skyline.
struct ThemeEmblem: View {
    @Environment(\.gameTheme) private var theme
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            if theme == .sakura {
                for index in 0..<16 {
                    let angle = Double(index) * .pi / 8
                    var ray = Path()
                    ray.move(to: CGPoint(x: center.x + cos(angle) * 36, y: center.y + sin(angle) * 36))
                    ray.addLine(to: CGPoint(x: center.x + cos(angle) * 100, y: center.y + sin(angle) * 100))
                    context.stroke(ray, with: .color(theme.accent.opacity(0.24)), lineWidth: index.isMultiple(of: 2) ? 3 : 1)
                }
                context.fill(Path(ellipseIn: CGRect(x: center.x - 30, y: center.y - 30, width: 60, height: 60)), with: .color(theme.secondary))
            } else if theme == .cyber {
                for index in 0..<11 {
                    let height = CGFloat(20 + (index * 37) % 65)
                    let rect = CGRect(x: center.x - 88 + CGFloat(index) * 16, y: 96 - height, width: 12, height: height)
                    context.fill(Path(rect), with: .color(theme.secondary.opacity(0.25)))
                    context.stroke(Path(rect), with: .color(theme.accent.opacity(0.5)), lineWidth: 1)
                }
            } else {
                for index in 0..<3 {
                    let rect = CGRect(x: center.x - 42 + CGFloat(index) * 24, y: center.y - 32 + CGFloat(index) * 10, width: 54, height: 54)
                    context.fill(Path(roundedRect: rect, cornerRadius: 14), with: .color(theme.accent.opacity(0.15 + Double(index) * 0.18)))
                }
            }
        }.frame(height: 110).accessibilityHidden(true)
    }
}
