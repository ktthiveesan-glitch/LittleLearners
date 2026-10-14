//
//  BadgeServiceTests.swift
//  LittleLearnersTests
//

import Testing
import SwiftData
@testable import LittleLearners

/// Checks the rules for winning badges and that a badge is saved only once.
@MainActor
struct BadgeServiceTests {
    private let englishIDs = Set(LearningContent.englishLetters.map(\.id))
    private let shapeIDs = Set(LearningContent.shapes.map(\.id))

    @Test("No stars and nothing completed gives no badges")
    func nothingEarned() {
        #expect(BadgeService.qualifyingBadges(stars: 0, completedItemIDs: []).isEmpty)
    }

    @Test("Star badges are won at 1, 10 and 50 stars",
          arguments: [(1, Set<Badge>([.firstStar])),
                      (9, Set<Badge>([.firstStar])),
                      (10, Set<Badge>([.firstStar, .tenStars])),
                      (49, Set<Badge>([.firstStar, .tenStars])),
                      (50, Set<Badge>([.firstStar, .tenStars, .fiftyStars]))])
    func starBadges(stars: Int, expected: Set<Badge>) {
        #expect(BadgeService.qualifyingBadges(stars: stars, completedItemIDs: []) == expected)
    }

    @Test("Tracing every English letter wins the English Letters badge")
    func allEnglishLetters() {
        #expect(BadgeService.qualifyingBadges(stars: 0, completedItemIDs: englishIDs) == [.englishLetters])
    }

    @Test("Missing one English letter does not win the badge")
    func almostAllEnglishLetters() {
        var ids = englishIDs
        ids.remove("en-Z")
        #expect(BadgeService.qualifyingBadges(stars: 0, completedItemIDs: ids).isEmpty)
    }

    @Test("Finishing all shapes wins the Shape Champion badge")
    func shapesChampion() {
        #expect(BadgeService.qualifyingBadges(stars: 0, completedItemIDs: shapeIDs) == [.shapesChampion])
    }

    @Test("Sinhala, Tamil and number badges each need their own full list")
    func otherListBadges() {
        let sinhala = Set(LearningContent.sinhalaVowels.map(\.id))
        let tamil = Set(LearningContent.tamilVowels.map(\.id))
        let numbers = Set(LearningContent.numbers.map(\.id))
        #expect(BadgeService.qualifyingBadges(stars: 0, completedItemIDs: sinhala) == [.sinhalaLetters])
        #expect(BadgeService.qualifyingBadges(stars: 0, completedItemIDs: tamil) == [.tamilLetters])
        #expect(BadgeService.qualifyingBadges(stars: 0, completedItemIDs: numbers) == [.allNumbers])
    }

    @Test("awardNewBadges saves a new badge once and not a second time")
    func awardsOnlyOnce() throws {
        let container = try TestSupport.makeContainer()
        let profile = ChildProfile(name: "Test", avatar: "🐻", stars: 1)
        container.mainContext.insert(profile)

        let first = BadgeService.awardNewBadges(for: profile)
        #expect(first == [.firstStar])

        let second = BadgeService.awardNewBadges(for: profile)
        #expect(second.isEmpty)

        #expect(profile.badges.map(\.badgeID) == [Badge.firstStar.id])
        let saved = try container.mainContext.fetch(FetchDescriptor<EarnedBadge>())
        #expect(saved.count == 1)
    }
}
