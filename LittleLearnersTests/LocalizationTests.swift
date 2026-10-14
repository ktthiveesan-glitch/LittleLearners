//
//  LocalizationTests.swift
//  LittleLearnersTests
//

import Testing
import Foundation
@testable import LittleLearners

/// Checks that texts are looked up in the language chosen in the app.
@MainActor
struct LocalizationTests {
    @Test("Each language has the right code, script and its own name")
    func languages() {
        #expect(AppLanguage.allCases.map(\.rawValue) == ["en", "si", "ta"])
        #expect(AppLanguage.sinhala.script == .sinhala)
        #expect(AppLanguage.tamil.displayName == "தமிழ்")
        #expect(AppLanguage.english.locale.identifier == "en")
    }

    @Test("A text is translated into the requested language")
    func translatedText() {
        #expect(AppLanguage.english.text("One") == "One")
        #expect(AppLanguage.sinhala.text("One") == "එක")
        #expect(AppLanguage.tamil.text("One") == "ஒன்று")
    }

    @Test("Category and badge names are translated")
    func translatedTitles() {
        #expect(AppLanguage.tamil.text(LearningCategory.letters.title) == "எழுத்துகள்")
        #expect(AppLanguage.sinhala.text(Badge.firstStar.title) == "පළමු තරුව")
    }

    @Test("Every badge has a title and a way to earn it in all three languages")
    func badgesAreComplete() {
        for badge in Badge.allCases {
            #expect(!badge.emoji.isEmpty)
            for language in AppLanguage.allCases {
                #expect(!language.text(badge.title).isEmpty)
                #expect(!language.text(badge.howToEarn).isEmpty)
            }
        }
    }

    @Test("The star count uses the singular for one and the plural for many")
    func starPlural() {
        let one = String(localized: "\(1) stars", locale: Locale(identifier: "en"))
        let five = String(localized: "\(5) stars", locale: Locale(identifier: "en"))
        #expect(one == "1 star")
        #expect(five == "5 stars")
    }
}
