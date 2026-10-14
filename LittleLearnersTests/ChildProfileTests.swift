//
//  ChildProfileTests.swift
//  LittleLearnersTests
//

import Testing
import Foundation
import SwiftData
@testable import LittleLearners

/// Tests for multiple child profiles: each child's data is separate, deleting a child deletes
/// their data, and a parent can edit a child.
@MainActor
struct ChildProfileTests {
    private let container: ModelContainer
    private let nimal = ChildProfile(name: "Nimal", avatar: "🐻")
    private let kavya = ChildProfile(name: "Kavya", avatar: "🐱")

    init() throws {
        container = try TestSupport.makeContainer()
        container.mainContext.insert(nimal)
        container.mainContext.insert(kavya)
    }

    @Test("Every child gets their own id")
    func uniqueIDs() {
        #expect(nimal.profileID != kavya.profileID)
    }

    @Test("Progress saved for one child does not appear for another")
    func progressIsSeparate() {
        ProgressService.markCompleted(LearningContent.englishLetters[0], for: nimal)

        #expect(nimal.progress.map(\.itemID) == ["en-A"])
        #expect(nimal.progress.first?.profile === nimal)
        #expect(kavya.progress.isEmpty)
    }

    @Test("Two children can each complete the same item")
    func sameItemForTwoChildren() throws {
        let letter = LearningContent.englishLetters[0]
        ProgressService.markCompleted(letter, for: nimal)
        ProgressService.markCompleted(letter, for: kavya)
        ProgressService.markCompleted(letter, for: nimal)   // a second time: no duplicate

        #expect(nimal.progress.count == 1)
        #expect(kavya.progress.count == 1)
        #expect(try container.mainContext.fetch(FetchDescriptor<LessonProgress>()).count == 2)
    }

    @Test("Badges are won by the child who earned them, not by the other child")
    func badgesAreSeparate() {
        nimal.stars = 10
        #expect(BadgeService.awardNewBadges(for: nimal) == [.firstStar, .tenStars])
        #expect(BadgeService.awardNewBadges(for: kavya).isEmpty)
        #expect(nimal.badges.count == 2)
        #expect(kavya.badges.isEmpty)
    }

    @Test("A tracing attempt and its star go to the child who traced")
    func tracingBelongsToTheChild() async {
        let viewModel = TracingViewModel(item: LearningContent.tamilVowels[0])
        viewModel.canvasSizeChanged(to: CGSize(width: 300, height: 300))
        viewModel.strokes = [[CGPoint(x: 0.05, y: 0.05), CGPoint(x: 0.95, y: 0.95)]]
        await viewModel.check(profile: kavya)

        #expect(kavya.attempts.count == 1)
        #expect(nimal.attempts.isEmpty)
    }

    @Test("Deleting a child also deletes their progress, attempts and badges (cascade), and nobody else's")
    func cascadeDelete() throws {
        let context = container.mainContext
        for child in [nimal, kavya] {
            child.progress.append(LessonProgress(itemID: "en-A", category: .letters, isCompleted: true))
            child.attempts.append(TracingAttempt(itemID: "en-A", character: "A", isCorrect: true, score: 1))
            child.badges.append(EarnedBadge(badgeID: Badge.firstStar.id))
        }
        try context.save()

        context.delete(nimal)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<ChildProfile>()).map(\.name) == ["Kavya"])
        #expect(try context.fetch(FetchDescriptor<LessonProgress>()).count == 1)
        #expect(try context.fetch(FetchDescriptor<TracingAttempt>()).count == 1)
        #expect(try context.fetch(FetchDescriptor<EarnedBadge>()).count == 1)
        #expect(kavya.progress.count == 1)
    }

    @Test("Editing a child saves the trimmed name and the new avatar")
    func editProfile() {
        let viewModel = ProfileEditViewModel(profile: nimal)
        #expect(viewModel.name == "Nimal")
        #expect(viewModel.avatar == "🐻")

        viewModel.name = "  Nimal Perera "
        viewModel.avatar = "🦁"
        viewModel.save()

        #expect(nimal.name == "Nimal Perera")
        #expect(nimal.avatar == "🦁")
    }

    @Test("Editing cannot save an empty name")
    func editNeedsName() {
        let viewModel = ProfileEditViewModel(profile: nimal)
        viewModel.name = "   "
        #expect(!viewModel.canSave)
        viewModel.save()
        #expect(nimal.name == "Nimal")
    }

    @Test("Deleting the selected child also forgets the selection")
    func deleteSelectedChild() throws {
        let defaults = UserDefaults.standard
        let previous = defaults.string(forKey: ChildProfile.activeProfileKey)
        defer { defaults.set(previous, forKey: ChildProfile.activeProfileKey) }

        defaults.set(nimal.profileID.uuidString, forKey: ChildProfile.activeProfileKey)
        ProfileEditViewModel(profile: nimal).delete(in: container.mainContext)
        try container.mainContext.save()

        #expect(defaults.string(forKey: ChildProfile.activeProfileKey) == nil)
        #expect(try container.mainContext.fetch(FetchDescriptor<ChildProfile>()).map(\.name) == ["Kavya"])
    }

    @Test("Deleting a child who is not selected keeps the selection")
    func deleteOtherChild() throws {
        let defaults = UserDefaults.standard
        let previous = defaults.string(forKey: ChildProfile.activeProfileKey)
        defer { defaults.set(previous, forKey: ChildProfile.activeProfileKey) }

        defaults.set(nimal.profileID.uuidString, forKey: ChildProfile.activeProfileKey)
        ProfileEditViewModel(profile: kavya).delete(in: container.mainContext)

        #expect(defaults.string(forKey: ChildProfile.activeProfileKey) == nimal.profileID.uuidString)
    }
}
