//
//  EarnedBadge.swift
//  LittleLearners
//

import Foundation
import SwiftData

/// A badge (sticker) the child has won. Shown in the Rewards sticker book.
@Model
final class EarnedBadge {
    /// A short fixed name for the badge, e.g. "first-star". Each child has each badge only once.
    var badgeID: String

    /// When the child won the badge.
    var earnedAt: Date

    /// The child who won the badge. It is set by adding the badge to `ChildProfile.badges`.
    var profile: ChildProfile?

    init(badgeID: String, earnedAt: Date = .now) {
        self.badgeID = badgeID
        self.earnedAt = earnedAt
    }
}
