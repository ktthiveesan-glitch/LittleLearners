//
//  ProfilePickerView.swift
//  LittleLearners
//

import SwiftUI
import SwiftData

/// "Who is learning today?" Shown when the app opens and at least one child exists.
/// Each child is a big round card with their avatar and name. Tapping a card selects that child and
/// opens Home. The "+" card opens onboarding to add another child.
struct ProfilePickerView: View {
    /// All saved children, oldest first.
    let profiles: [ChildProfile]

    /// The id of the child who was selected last time. Their card gets a coloured ring.
    let selectedProfileID: String

    /// Shared with Home, so the tapped avatar can move into its place there (`matchedGeometryEffect`).
    let avatarNamespace: Namespace.ID

    /// Called with the chosen (or newly added) child.
    let onSelect: (ChildProfile) -> Void

    /// Becomes true when the screen appears. The cards animate from small to full size when it changes.
    @State private var hasAppeared = false

    /// True while the onboarding screen for a new child is showing.
    @State private var isAddingChild = false

    /// Width of one card at the user's text size.
    @ScaledMetric private var scaledCardWidth: CGFloat = 130

    /// The width actually used: it grows with the text size but stops at 180 points, so two cards fit in a row.
    private var cardWidth: CGFloat {
        min(scaledCardWidth, 180)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.extraLarge) {
                Text("Who is learning today?")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: cardWidth), spacing: Theme.Spacing.large)],
                          spacing: Theme.Spacing.large) {
                    ForEach(Array(profiles.enumerated()), id: \.element.profileID) { index, profile in
                        profileCard(for: profile)
                            .modifier(appearAnimation(position: index))
                    }
                    addCard
                        .modifier(appearAnimation(position: profiles.count))
                }
            }
            .padding(Theme.Spacing.large)
            .frame(maxWidth: 800)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.background)
        .onAppear { hasAppeared = true }
        // Adding a child reuses the onboarding screen, shown over the picker.
        .fullScreenCover(isPresented: $isAddingChild) {
            OnboardingView(onFinished: { newProfile in
                isAddingChild = false
                onSelect(newProfile)
            }, onCancel: {
                isAddingChild = false
            })
        }
    }

    /// One child: avatar in a big circle with the name underneath.
    private func profileCard(for profile: ChildProfile) -> some View {
        let isLastSelected = profile.profileID.uuidString == selectedProfileID
        return Button {
            onSelect(profile)
        } label: {
            VStack(spacing: Theme.Spacing.small) {
                Text(profile.avatar)
                    .font(.system(size: cardWidth * 0.5))
                    .frame(width: cardWidth, height: cardWidth)
                    .background(Theme.card, in: Circle())
                    // Same id and namespace as the avatar on Home: this is what makes it fly there.
                    .matchedGeometryEffect(id: profile.profileID, in: avatarNamespace)
                    .overlay(Circle().stroke(Theme.primary, lineWidth: isLastSelected ? 5 : 0))
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
                Text(profile.name)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .bouncyPress()
        .accessibilityLabel(Text(profile.name))
        .accessibilityAddTraits(isLastSelected ? .isSelected : [])
    }

    /// The "+" card that adds a new child.
    private var addCard: some View {
        Button {
            isAddingChild = true
        } label: {
            VStack(spacing: Theme.Spacing.small) {
                Image(systemName: "plus")
                    .font(.system(size: cardWidth * 0.4, weight: .bold))
                    .foregroundStyle(Theme.primary)
                    .frame(width: cardWidth, height: cardWidth)
                    .background(Theme.primary.opacity(0.15), in: Circle())
                    .overlay(Circle().stroke(Theme.primary, style: StrokeStyle(lineWidth: 3, dash: [8, 8])))
                Text("Add child")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .bouncyPress()
    }

    /// The entrance animation: each card grows to full size with a spring, one slightly after the other.
    private func appearAnimation(position: Int) -> some ViewModifier {
        CardAppearModifier(hasAppeared: hasAppeared, delay: Double(position) * 0.1)
    }
}

/// Scales and fades a card in when `hasAppeared` becomes true, after a short delay.
private struct CardAppearModifier: ViewModifier {
    let hasAppeared: Bool
    let delay: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(hasAppeared ? 1 : 0.5)
            .opacity(hasAppeared ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay), value: hasAppeared)
    }
}

#Preview {
    @Previewable @Namespace var namespace
    ProfilePickerView(profiles: [PreviewData.profile], selectedProfileID: "",
                      avatarNamespace: namespace, onSelect: { _ in })
        .modelContainer(PreviewData.container)
}
