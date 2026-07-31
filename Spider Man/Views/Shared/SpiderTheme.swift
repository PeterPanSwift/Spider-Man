import SwiftUI

enum SpiderTheme {
    static let signalRed = Color(red: 0.92, green: 0.08, blue: 0.14)
    static let electricBlue = Color(red: 0.08, green: 0.38, blue: 0.92)
    static let midnight = Color(red: 0.025, green: 0.035, blue: 0.075)
    static let ink = Color(red: 0.055, green: 0.065, blue: 0.11)
    static let card = Color.white.opacity(0.075)

    static let background = LinearGradient(
        colors: [midnight, ink, Color.black],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct SpiderBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isDrifting = false

    var body: some View {
        ZStack {
            SpiderTheme.background
            Circle()
                .fill(SpiderTheme.signalRed.opacity(0.18))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .scaleEffect(isDrifting ? 1.16 : 0.9)
                .offset(
                    x: isDrifting ? -90 : -170,
                    y: isDrifting ? -230 : -310
                )
            Circle()
                .fill(SpiderTheme.electricBlue.opacity(0.14))
                .frame(width: 280, height: 280)
                .blur(radius: 100)
                .scaleEffect(isDrifting ? 0.88 : 1.14)
                .offset(
                    x: isDrifting ? 120 : 190,
                    y: isDrifting ? 240 : 330
                )
        }
        .animation(
            reduceMotion
                ? nil
                : .easeInOut(duration: 8).repeatForever(autoreverses: true),
            value: isDrifting
        )
        .onAppear {
            isDrifting = !reduceMotion
        }
        .onChange(of: reduceMotion) { _, shouldReduceMotion in
            isDrifting = !shouldReduceMotion
        }
        .ignoresSafeArea()
    }
}

private struct CinematicScrollRevealModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let axis: Axis

    func body(content: Content) -> some View {
        let shouldReduceMotion = reduceMotion

        content
            .scrollTransition(.interactive, axis: axis) { content, phase in
                content
                    .opacity(
                        shouldReduceMotion || phase.isIdentity
                            ? 1
                            : 0.42
                    )
                    .scaleEffect(
                        shouldReduceMotion || phase.isIdentity
                            ? 1
                            : 0.9
                    )
                    .offset(
                        x: shouldReduceMotion || axis == .vertical
                            ? 0
                            : phase.value * 22,
                        y: shouldReduceMotion || axis == .horizontal
                            ? 0
                            : phase.value * 26
                    )
                    .rotationEffect(
                        .degrees(
                            shouldReduceMotion
                                ? 0
                                : phase.value * (axis == .horizontal ? 2.5 : 1.2)
                        )
                    )
            }
    }
}

extension View {
    func cinematicScrollReveal(axis: Axis = .vertical) -> some View {
        modifier(CinematicScrollRevealModifier(axis: axis))
    }
}

struct SectionTitle: View {
    let eyebrow: String?
    let title: String

    init(_ title: String, eyebrow: String? = nil) {
        self.title = title
        self.eyebrow = eyebrow
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let eyebrow {
                Text(eyebrow.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(1.8)
                    .foregroundStyle(SpiderTheme.signalRed)
            }
            Text(title)
                .font(.title2.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(18)
            .background(SpiderTheme.card, in: RoundedRectangle(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
    }
}

struct RemoteArtwork: View {
    let url: URL?
    let cornerRadius: CGFloat
    let fallbackSymbol: String

    init(
        url: URL?,
        cornerRadius: CGFloat = 20,
        fallbackSymbol: String = "spider.fill"
    ) {
        self.url = url
        self.cornerRadius = cornerRadius
        self.fallbackSymbol = fallbackSymbol
    }

    var body: some View {
        ZStack {
            if let url {
                AsyncImage(url: url) { phase in
                    ZStack {
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            ArtworkPlaceholder(symbol: fallbackSymbol)
                        case .empty:
                            ArtworkPlaceholder(symbol: fallbackSymbol)
                                .overlay {
                                    ProgressView()
                                        .tint(.white)
                                }
                        @unknown default:
                            ArtworkPlaceholder(symbol: fallbackSymbol)
                        }
                    }
                }
            } else {
                ArtworkPlaceholder(symbol: fallbackSymbol)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        }
        .clipped()
    }
}

struct ArtworkPlaceholder: View {
    let symbol: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [SpiderTheme.signalRed, SpiderTheme.electricBlue, SpiderTheme.midnight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: symbol)
                .font(.system(size: 42, weight: .black))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

struct CapsuleTag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(.thinMaterial, in: Capsule())
    }
}
