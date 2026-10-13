//
//  Theme.swift
//  LittleLearners
//

import SwiftUI

/// The single place for the app's colours, spacing and corner sizes.
/// Views use `Theme` instead of writing colours or numbers directly,
/// so the whole app looks the same and is easy to change.
enum Theme {

    // MARK: - Colours
    // Each colour lives in Assets.xcassets with a light and a dark variant.
    // Xcode creates the names (.brandPrimary etc.) from the asset names,
    // so a spelling mistake becomes a build error.

    /// Main brand colour (blue). Used for the most important buttons and titles.
    static let primary = Color(.brandPrimary)

    /// Second brand colour (orange). Used for the second category and highlights.
    static let secondary = Color(.brandSecondary)

    /// Extra pop colour (pink). Used for small details such as stars and badges.
    static let accent = Color(.brandAccent)

    /// The colour behind every screen.
    static let background = Color(.appBackground)

    /// The colour of cards that sit on top of the background.
    static let card = Color(.cardBackground)

    /// Green colour shown when the child gets something right.
    static let success = Color(.success)

    /// Each category has its own colour so children can tell them apart.
    static func color(for category: LearningCategory) -> Color {
        switch category {
        case .letters: primary
        case .numbers: secondary
        case .shapes: accent
        }
    }

    // MARK: - Spacing

    /// Standard gaps between views, in points.
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }

    // MARK: - Corner radius

    /// Standard rounded-corner sizes, in points.
    enum CornerRadius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 20
        static let large: CGFloat = 28
    }

    // MARK: - Touch targets

    /// Smallest size for anything a child taps (60×60 points), because small fingers need big buttons.
    static let minTouchTarget: CGFloat = 60
}
