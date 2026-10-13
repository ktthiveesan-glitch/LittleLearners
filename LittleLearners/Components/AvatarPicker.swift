//
//  AvatarPicker.swift
//  LittleLearners
//

import SwiftUI

/// A grid of emoji buttons for choosing a child's avatar. The chosen one gets a coloured ring.
/// Used on the onboarding screen and when a parent edits a child.
struct AvatarPicker: View {
    /// The avatar emojis a child can choose from.
    static let avatars = ["🐻", "🐱", "🐶", "🦁", "🐰", "🐼", "🦊", "🐸", "🐵", "🦄", "🐯", "🐨"]

    /// The chosen avatar.
    @Binding var selection: String

    /// Size of one avatar button at the user's text size.
    @ScaledMetric private var scaledAvatarSize: CGFloat = 64

    /// The size actually used: it grows with the text size but stops at 96 points,
    /// so several avatars still fit in a row. It is never below the 60-point touch target.
    private var avatarSize: CGFloat {
        min(scaledAvatarSize, 96)
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: avatarSize), spacing: Theme.Spacing.small)],
                  spacing: Theme.Spacing.small) {
            ForEach(Self.avatars, id: \.self) { avatar in
                avatarButton(avatar)
            }
        }
    }

    /// One avatar button. VoiceOver reads the emoji's own name (for example "bear").
    private func avatarButton(_ avatar: String) -> some View {
        let isSelected = selection == avatar
        return Button {
            selection = avatar
        } label: {
            Text(avatar)
                .font(.largeTitle)
                .frame(width: avatarSize, height: avatarSize)
                .background(Theme.card, in: Circle())
                .overlay(Circle().stroke(Theme.primary, lineWidth: isSelected ? 4 : 0))
        }
        // A custom button style also matters inside a List: with the default style,
        // a tap anywhere on the row would press every avatar in it at once.
        .bouncyPress()
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var avatar = AvatarPicker.avatars[0]
    AvatarPicker(selection: $avatar)
        .padding()
        .background(Theme.background)
}
