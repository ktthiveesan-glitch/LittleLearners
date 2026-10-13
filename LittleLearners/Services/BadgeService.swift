//
//  BadgeService.swift
//  LittleLearners
//

import Foundation
import SwiftData

/// Decides which badges a child has won and saves the new ones.
enum BadgeService {

    /// The rules. Given the child's star count and the ids of the items they have completed,
    /// returns every badge they qualify for. It has no database code, so it is easy to test.
    static func qualifyingBadges(stars: Int, completedItemIDs: Set<String>) -> Set<Badge> {
        var badges: Set<Badge> = []

        if stars >= 1 { badges.insert(.firstStar) }
        if stars >= 10 { badges.insert(.tenStars) }
        if stars >= 50 { badges.insert(.fiftyStars) }

        if isAllCompleted(LearningContent.englishLetters, in: completedItemIDs) { badges.insert(.englishLetters) }
        if isAllCompleted(LearningContent.sinhalaVowels, in: completedItemIDs) { badges.insert(.sinhalaLetters) }
        if isAllCompleted(LearningContent.tamilVowels, in: completedItemIDs) { badges.insert(.tamilLetters) }
        if isAllCompleted(LearningContent.numbers, in: completedItemIDs) { badges.insert(.allNumbers) }
        if isAllCompleted(LearningContent.shapes, in: completedItemIDs) { badges.insert(.shapesChampion) }

        return badges
    }

    /// True when every item in the list is in the completed set.
    private static func isAllCompleted(_ items: [LearningItem], in completedItemIDs: Set<String>) -> Bool {
        items.allSatisfy { completedItemIDs.contains($0.id) }
    }

    /// Looks at one child's stars and progress, adds an `EarnedBadge` for each badge they have newly won,
    /// and returns those new badges. Call it after the child earns a star or completes something.
    @discardableResult
    static func awardNewBadges(for profile: ChildProfile) -> [Badge] {
        let completedItemIDs = Set(profile.progress.filter(\.isCompleted).map(\.itemID))
        let alreadyEarnedIDs = Set(profile.badges.map(\.badgeID))

        // Keep the fixed badge order, and skip badges the child already has.
        let qualifying = qualifyingBadges(stars: profile.stars, completedItemIDs: completedItemIDs)
        let newBadges = Badge.allCases.filter { qualifying.contains($0) && !alreadyEarnedIDs.contains($0.id) }

        for badge in newBadges {
            profile.badges.append(EarnedBadge(badgeID: badge.id))
        }
        return newBadges
    }
}
