//
//  LearningContentTests.swift
//  LittleLearnersTests
//

import Testing
@testable import LittleLearners

/// Checks that the built-in letters, numbers and shapes are complete.
@MainActor
struct LearningContentTests {
    /// Every item in the app, from all five lists.
    private var allItems: [LearningItem] {
        LearningContent.englishLetters + LearningContent.sinhalaVowels + LearningContent.tamilVowels
            + LearningContent.numbers + LearningContent.shapes
    }

    @Test("No item has an empty character, word, emoji or id")
    func noEmptyItems() {
        for item in allItems {
            #expect(!item.id.isEmpty)
            #expect(!item.character.isEmpty, "Empty character for \(item.id)")
            #expect(!item.word.isEmpty, "Empty word for \(item.id)")
            #expect(!item.emoji.isEmpty, "Empty emoji for \(item.id)")
        }
    }

    @Test("Each list has the expected number of items")
    func listSizes() {
        #expect(LearningContent.englishLetters.count == 26)
        #expect(LearningContent.sinhalaVowels.count == 14)
        #expect(LearningContent.tamilVowels.count == 12)
        #expect(LearningContent.numbers.count == 10)
        #expect(LearningContent.shapes.count == 6)
    }

    @Test("Every item id is unique, because progress is saved by id")
    func uniqueIDs() {
        let ids = allItems.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test("Letters know their script; numbers and shapes have none")
    func scriptsAndCategories() {
        #expect(LearningContent.englishLetters.allSatisfy { $0.script == .english && $0.category == .letters })
        #expect(LearningContent.sinhalaVowels.allSatisfy { $0.script == .sinhala && $0.category == .letters })
        #expect(LearningContent.tamilVowels.allSatisfy { $0.script == .tamil && $0.category == .letters })
        #expect(LearningContent.numbers.allSatisfy { $0.script == nil && $0.category == .numbers })
        #expect(LearningContent.shapes.allSatisfy { $0.script == nil && $0.category == .shapes })
    }

    @Test("siblings(of:) returns the list the item belongs to")
    func siblings() {
        let tamilLetter = LearningContent.tamilVowels[3]
        #expect(LearningContent.siblings(of: tamilLetter).map(\.id) == LearningContent.tamilVowels.map(\.id))
        let number = LearningContent.numbers[0]
        #expect(LearningContent.siblings(of: number).count == 10)
    }
}
