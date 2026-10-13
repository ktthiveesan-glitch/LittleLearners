//
//  KidsCard.swift
//  LittleLearners
//

import SwiftUI

/// A rounded card with a soft shadow. Put any content inside it:
/// `KidsCard { Text("A") }`. Used for category cards, grid cells and the big lesson character.
struct KidsCard<Content: View>: View {
    /// The views shown inside the card.
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(Theme.Spacing.medium)
            .frame(maxWidth: .infinity)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.large))
            .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}

#Preview {
    KidsCard {
        Text(verbatim: "A")
            .font(.largeTitle)
    }
    .padding()
    .background(Theme.background)
}
