//
//  LessonViewModelTests.swift
//  LittleLearnersTests
//

import Testing
import SwiftData
@testable import LittleLearners

/// Tests for the view models of onboarding, the character grid and the lesson screen.
@MainActor
struct LessonViewModelTests {

    // MARK: - OnboardingViewModel

    @Test("Onboarding cannot be saved with an empty or blank name")
    func onboardingNeedsName() throws {
        let container = try TestSupport.makeContainer()
        let viewModel = OnboardingViewModel()
        #expect(!viewModel.canSave)

        viewModel.name = "   "
        #expect(!viewModel.canSave)
        #expect(viewModel.save(in: container.mainContext) == nil)
        #expect(try container.mainContext.fetch(FetchDescriptor<ChildProfile>()).isEmpty)
    }

    @Test("Onboarding saves a profile with the trimmed name and the chosen avatar")
    func onboardingSavesProfile() throws {
        let container = try TestSupport.makeContainer()
        let viewModel = OnboardingViewModel()
        viewModel.name = "  Nimal "
        viewModel.avatar = "🦁"
        #expect(viewModel.canSave)
        let saved = viewModel.save(in: container.mainContext)

        let profiles = try container.mainContext.fetch(FetchDescriptor<ChildProfile>())
        #expect(profiles.count == 1)
        #expect(profiles.first === saved)
        #expect(profiles.first?.name == "Nimal")
        #expect(profiles.first?.avatar == "🦁")
        #expect(profiles.first?.stars == 0)
    }

    // MARK: - CharacterGridViewModel

    @Test("The letters grid shows the script picker and the letters of the chosen script")
    func gridLetters() {
        let viewModel = CharacterGridViewModel(category: .letters)
        #expect(viewModel.showsScriptPicker)

        viewModel.script = .english
        #expect(viewModel.items.count == 26)
        viewModel.script = .sinhala
        #expect(viewModel.items.count == 14)
        viewModel.script = .tamil
        #expect(viewModel.items.count == 12)
        #expect(viewModel.items.first?.character == "அ")
    }

    @Test("The numbers grid has ten numbers and no script picker")
    func gridNumbers() {
        let viewModel = CharacterGridViewModel(category: .numbers)
        #expect(!viewModel.showsScriptPicker)
        #expect(viewModel.items.map(\.character) == (1...10).map(String.init))
    }

    // MARK: - LessonDetailViewModel

    @Test("A lesson starts on the chosen letter and can move forward and back")
    func lessonMovesBetweenLetters() {
        let viewModel = LessonDetailViewModel(item: LearningContent.englishLetters[1]) // B
        #expect(viewModel.item.character == "B")

        viewModel.goToNext()
        #expect(viewModel.item.character == "C")
        #expect(viewModel.isMovingForward)

        viewModel.goToPrevious()
        viewModel.goToPrevious()
        #expect(viewModel.item.character == "A")
        #expect(!viewModel.isMovingForward)
    }

    @Test("A lesson does not move before the first letter or after the last one")
    func lessonStopsAtEnds() {
        let first = LessonDetailViewModel(item: LearningContent.englishLetters[0])
        #expect(!first.hasPrevious)
        first.goToPrevious()
        #expect(first.item.character == "A")

        let last = LessonDetailViewModel(item: LearningContent.englishLetters[25])
        #expect(!last.hasNext)
        last.goToNext()
        #expect(last.item.character == "Z")
    }

    @Test("A lesson only moves inside its own list")
    func lessonStaysInItsList() {
        let viewModel = LessonDetailViewModel(item: LearningContent.tamilVowels[0])
        #expect(viewModel.items.count == 12)
        #expect(viewModel.items.allSatisfy { $0.script == .tamil })
    }
}
