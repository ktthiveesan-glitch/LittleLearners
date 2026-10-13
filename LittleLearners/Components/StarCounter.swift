//
//  StarCounter.swift
//  LittleLearners
//

import SwiftUI

/// A pill showing a star and how many stars the child has. VoiceOver reads "5 stars".
struct StarCounter: View {
    /// The number to show.
    let stars: Int

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text(verbatim: "\(stars)")
                .bold()
                // Makes the number roll to its new value when it changes inside an animation.
                .contentTransition(.numericText())
        }
        .font(.title2)
        .padding(.horizontal, Theme.Spacing.medium)
        .padding(.vertical, Theme.Spacing.small)
        .background(Theme.card, in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(stars) stars")
    }
}

#Preview {
    StarCounter(stars: 5)
        .padding()
        .background(Theme.background)
}
