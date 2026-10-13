//
//  ChildProfile.swift
//  LittleLearners
//

import Foundation
import SwiftData

/// One child who uses the app. A family can have several profiles; each is created with the
/// onboarding screen. If no `ChildProfile` is saved, the app shows onboarding straight away.
///
/// Everything a child earns hangs off their profile through the three relationships below,
/// so each child has their own progress, tracing history and badges.
@Model
final class ChildProfile {
    /// The key the selected child's id is saved under in `UserDefaults` (used with `@AppStorage`).
    static let activeProfileKey = "activeProfileID"

    /// A fixed id for this child. Its text form is what we save to remember which child is selected.
    var profileID: UUID = UUID()

    /// The child's first name, typed in during onboarding.
    var name: String

    /// The emoji the child picked as their picture, e.g. "🐻".
    var avatar: String

    /// Total stars the child has earned so far.
    var stars: Int

    /// When the profile was created. The profile picker shows the oldest profile first.
    var createdAt: Date

    /// This child's progress records. `deleteRule: .cascade` means: when the child is deleted,
    /// SwiftData deletes these records too. `inverse` names the property on the other side of the link.
    @Relationship(deleteRule: .cascade, inverse: \LessonProgress.profile)
    var progress: [LessonProgress] = []

    /// This child's tracing attempts. Deleted together with the child.
    @Relationship(deleteRule: .cascade, inverse: \TracingAttempt.profile)
    var attempts: [TracingAttempt] = []

    /// The badges this child has won. Deleted together with the child.
    @Relationship(deleteRule: .cascade, inverse: \EarnedBadge.profile)
    var badges: [EarnedBadge] = []

    init(name: String, avatar: String, stars: Int = 0, createdAt: Date = .now) {
        self.name = name
        self.avatar = avatar
        self.stars = stars
        self.createdAt = createdAt
    }
}
