//
//  HomeView.swift
//  LittleLearners
//

import SwiftUI
import SwiftData

/// The main menu. Shows a greeting, the star counter, one big card per category,
/// and buttons for the Rewards sticker book and the Parent area.
struct HomeView: View {
    /// The child using the app. Gives us the name, avatar and star count.
    let profile: ChildProfile

    /// Shared with the profile picker. The avatar here and the avatar on the picker card use the same id
    /// in this namespace, so SwiftUI moves the avatar between the two places (`matchedGeometryEffect`).
    let avatarNamespace: Namespace.ID

    /// Called when the avatar is tapped, to go back to the profile picker.
    let onSwitchProfile: () -> Void

    /// Becomes true when the screen appears. The cards animate from small to full size when it changes.
    @State private var hasAppeared = false

    /// Smallest width of a category card. The grid fits as many cards per row as the screen allows:
    /// one on an iPhone in portrait, three on an iPad or in landscape.
    @ScaledMetric private var cardMinWidth: CGFloat = 220

    /// Size of the emoji on a category card. Grows with the user's text size.
    @ScaledMetric private var cardEmojiSize: CGFloat = 64

    /// The user's text size setting. With the very large "accessibility" sizes,
    /// things that normally sit side by side are stacked so that nothing is cut off.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.large) {
                header
                categoryCards
                bottomButtons
            }
            .padding(Theme.Spacing.large)
            .frame(maxWidth: 1000)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.background)
        .navigationTitle("Little Learners")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { hasAppeared = true }
    }

    /// Avatar button and greeting on the left, star counter on the right.
    /// With very large text the star counter moves below the greeting instead.
    private var header: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Theme.Spacing.small))
            : AnyLayout(HStackLayout(spacing: Theme.Spacing.medium))
        return layout {
            HStack(spacing: Theme.Spacing.medium) {
                // Tapping the avatar goes back to "Who is learning today?".
                Button(action: onSwitchProfile) {
                    Text(profile.avatar)
                        .font(.largeTitle)
                        .frame(width: Theme.minTouchTarget, height: Theme.minTouchTarget)
                        .background(Theme.card, in: Circle())
                        .matchedGeometryEffect(id: profile.profileID, in: avatarNamespace)
                }
                .bouncyPress()
                .accessibilityLabel("Switch child")
                Text("Hi, \(profile.name)!")
                    .font(.title)
                    .bold()
                Spacer(minLength: 0)
            }
            StarCounter(stars: profile.stars)
        }
    }

    /// The three category cards in a grid that adapts to the screen width.
    private var categoryCards: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: cardMinWidth), spacing: Theme.Spacing.medium)],
                  spacing: Theme.Spacing.medium) {
            ForEach(Array(LearningCategory.allCases.enumerated()), id: \.element) { index, category in
                NavigationLink(value: route(for: category)) {
                    categoryCard(for: category)
                }
                .bouncyPress()
                // Gentle bounce on appear: each card grows to full size with a spring,
                // one slightly after the other.
                .scaleEffect(hasAppeared ? 1 : 0.6)
                .opacity(hasAppeared ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.12),
                           value: hasAppeared)
            }
        }
    }

    /// One card: the category emoji on a coloured circle with the category name below.
    private func categoryCard(for category: LearningCategory) -> some View {
        KidsCard {
            VStack(spacing: Theme.Spacing.medium) {
                // The emoji grows with the text size, but only up to 96 points,
                // so the three cards still fit on screen.
                Text(category.emoji)
                    .font(.system(size: min(cardEmojiSize, 96)))
                    .padding(Theme.Spacing.large)
                    .background(Theme.color(for: category).opacity(0.25), in: Circle())
                    .accessibilityHidden(true)
                Text(category.title)
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color.primary)
            }
            .padding(.vertical, Theme.Spacing.medium)
        }
    }

    /// Shapes opens the shapes game; letters and numbers open the character grid.
    private func route(for category: LearningCategory) -> Route {
        category == .shapes ? .shapesGame : .characterList(category)
    }

    /// The Rewards and Parents buttons, side by side (stacked with very large text).
    private var bottomButtons: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: Theme.Spacing.medium))
            : AnyLayout(HStackLayout(spacing: Theme.Spacing.medium))
        return layout {
            menuButton("Rewards", systemImage: "trophy.fill", color: Theme.secondary, route: .rewards)
            menuButton("Parents", systemImage: "lock.fill", color: Theme.primary, route: .parentArea)
        }
    }

    /// A wide button with an icon and a title that opens the given route.
    private func menuButton(_ title: LocalizedStringKey, systemImage: String, color: Color, route: Route) -> some View {
        NavigationLink(value: route) {
            Label(title, systemImage: systemImage)
                .font(.title3)
                .bold()
                .foregroundStyle(Color.primary)
                .padding(.horizontal, Theme.Spacing.medium)
                .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget)
                .background(color.opacity(0.25), in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        }
        .bouncyPress()
    }
}

#Preview {
    @Previewable @Namespace var namespace
    NavigationStack {
        HomeView(profile: PreviewData.profile, avatarNamespace: namespace, onSwitchProfile: {})
    }
}
