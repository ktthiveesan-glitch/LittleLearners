//
//  RewardsView.swift
//  LittleLearners
//

import SwiftUI
import SwiftData

/// The sticker book. Shows every badge in a grid; badges not won yet are greyed out.
/// Tap a badge to enlarge it, tap again to put it back. Long press to hear its name.
struct RewardsView: View {
    /// The selected child, put in the environment by `RootView`. Only this child's badges are shown.
    @Environment(ChildProfile.self) private var profile

    /// Remembers the enlarged badge and speaks badge names.
    @State private var viewModel = RewardsViewModel()

    /// Links the small sticker in the grid to the big one, so SwiftUI can animate between them.
    @Namespace private var stickerNamespace

    /// Smallest width of one sticker at the user's text size.
    @ScaledMetric private var scaledStickerWidth: CGFloat = 96

    /// The width actually used: it grows with the text size but stops at 150 points,
    /// so at least two stickers fit in a row. The grid fits as many per row as the screen allows.
    private var stickerMinWidth: CGFloat {
        min(scaledStickerWidth, 150)
    }

    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: stickerMinWidth), spacing: Theme.Spacing.large)],
                          spacing: Theme.Spacing.large) {
                    ForEach(Badge.allCases) { badge in
                        gridCell(for: badge)
                    }
                }
                .padding(Theme.Spacing.large)
            }

            if let badge = viewModel.selectedBadge {
                enlargedBadge(badge)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
        .navigationTitle("Rewards")
    }

    /// True if the child has won the badge.
    private func isEarned(_ badge: Badge) -> Bool {
        profile.badges.contains { $0.badgeID == badge.id }
    }

    /// One sticker in the grid with its name underneath.
    private func gridCell(for badge: Badge) -> some View {
        VStack(spacing: Theme.Spacing.small) {
            // The clear square keeps the cell's space while its sticker is away being shown big.
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    if viewModel.selectedBadge != badge {
                        BadgeSticker(badge: badge, isEarned: isEarned(badge))
                            .matchedGeometryEffect(id: badge.id, in: stickerNamespace)
                    }
                }
            Text(badge.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(isEarned(badge) ? Color.primary : Color.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture { select(badge) }
        .onLongPressGesture { viewModel.speakName(of: badge) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(badge.title))
        .accessibilityValue(isEarned(badge) ? Text("Earned") : Text("Locked"))
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to make it bigger")
        .accessibilityAction(named: "Listen") { viewModel.speakName(of: badge) }
    }

    /// The enlarged badge on a dimmed background, with its name and how to win it.
    private func enlargedBadge(_ badge: Badge) -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: Theme.Spacing.medium) {
                // Same id and namespace as the grid sticker: this is what makes it grow from its cell.
                BadgeSticker(badge: badge, isEarned: isEarned(badge))
                    .matchedGeometryEffect(id: badge.id, in: stickerNamespace)
                    .frame(maxWidth: 280, maxHeight: 280)
                    .onLongPressGesture { viewModel.speakName(of: badge) }
                VStack(spacing: Theme.Spacing.small) {
                    Text(badge.title)
                        .font(.largeTitle)
                        .bold()
                    Text(isEarned(badge) ? "You won this badge!" : badge.howToEarn)
                        .font(.title3)
                }
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .transition(.opacity)
            }
            .padding(Theme.Spacing.large)
        }
        .contentShape(Rectangle())
        .onTapGesture { select(nil) }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to close")
    }

    /// Enlarges a badge, or closes the enlarged one when given `nil`.
    private func select(_ badge: Badge?) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            viewModel.selectedBadge = badge
        }
    }
}

#Preview {
    NavigationStack {
        RewardsView()
    }
    .modelContainer(PreviewData.container)
    .environment(PreviewData.profile)
}
