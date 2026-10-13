//
//  ConfettiView.swift
//  LittleLearners
//

import SwiftUI

/// One piece of confetti with its own random look and timing.
struct ConfettiPiece: Identifiable {
    let id = UUID()
    /// Horizontal position, from 0.0 (left edge) to 1.0 (right edge).
    let x: CGFloat
    let color: Color
    /// Seconds to wait before this piece starts falling.
    let delay: Double
    /// Seconds this piece takes to fall.
    let duration: Double
    /// How far the piece turns while falling, in degrees.
    let spin: Double

    /// Makes `count` pieces with random values.
    static func makeRandom(count: Int) -> [ConfettiPiece] {
        let colors = [Theme.primary, Theme.secondary, Theme.accent, Theme.success, Color.yellow]
        return (0..<count).map { _ in
            ConfettiPiece(x: .random(in: 0...1),
                          color: colors.randomElement() ?? Theme.primary,
                          delay: .random(in: 0...0.5),
                          duration: .random(in: 1.2...2.2),
                          spin: .random(in: 180...720))
        }
    }
}

/// A burst of coloured paper pieces that fall from the top of the screen to the bottom.
/// Put it in an `.overlay` when the child gets something right.
struct ConfettiView: View {
    /// The pieces. Kept in `@State` so the random values are made once and do not change mid-fall.
    @State private var pieces = ConfettiPiece.makeRandom(count: 50)

    /// False at first (pieces wait above the screen); set to true on appear to start the fall.
    @State private var isFalling = false

    var body: some View {
        GeometryReader { geometry in
            ForEach(pieces) { piece in
                RoundedRectangle(cornerRadius: 2)
                    .fill(piece.color)
                    .frame(width: 10, height: 16)
                    .rotationEffect(.degrees(isFalling ? piece.spin : 0))
                    .position(x: piece.x * geometry.size.width,
                              y: isFalling ? geometry.size.height + 40 : -40)
                    .animation(.easeIn(duration: piece.duration).delay(piece.delay), value: isFalling)
            }
        }
        // Confetti is decoration only: touches pass through it and VoiceOver ignores it.
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear { isFalling = true }
    }
}

#Preview {
    ConfettiView()
}
