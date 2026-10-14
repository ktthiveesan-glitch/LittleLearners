//
//  HandwritingRecognizerTests.swift
//  LittleLearnersTests
//

import Testing
@testable import LittleLearners

/// Checks how the text that Vision reads is compared with the expected character.
/// (Vision itself is not tested here: these tests only cover our own matching rules.)
@MainActor
struct HandwritingRecognizerTests {
    @Test("Vision is used for English letters and digits only")
    func whichItemsUseVision() {
        #expect(HandwritingRecognizer.canVisionRead(LearningContent.englishLetters[0]))
        #expect(HandwritingRecognizer.canVisionRead(LearningContent.numbers[0]))
        #expect(!HandwritingRecognizer.canVisionRead(LearningContent.sinhalaVowels[0]))
        #expect(!HandwritingRecognizer.canVisionRead(LearningContent.tamilVowels[0]))
    }

    @Test("The expected letter repeated in all three copies matches")
    func threeCopiesMatch() {
        #expect(HandwritingRecognizer.matches("AAA", expected: "A", copies: 3))
        #expect(HandwritingRecognizer.matches("A A A", expected: "A", copies: 3))
    }

    @Test("Two correct copies out of three is enough; one is not")
    func majorityRule() {
        #expect(HandwritingRecognizer.matches("AAN", expected: "A", copies: 3))
        #expect(!HandwritingRecognizer.matches("ANN", expected: "A", copies: 3))
    }

    @Test("Upper and lower case count as the same letter")
    func caseIsIgnored() {
        #expect(HandwritingRecognizer.matches("sss", expected: "S", copies: 3))
    }

    @Test("A different letter does not match")
    func wrongLetter() {
        #expect(!HandwritingRecognizer.matches("BBB", expected: "A", copies: 3))
        #expect(!HandwritingRecognizer.matches("", expected: "A", copies: 1))
    }

    @Test("Look-alike characters are accepted: 0 for O, and l or 1 for I")
    func lookalikes() {
        #expect(HandwritingRecognizer.matches("000", expected: "O", copies: 3))
        #expect(HandwritingRecognizer.matches("l1|", expected: "I", copies: 3))
        #expect(HandwritingRecognizer.matches("I", expected: "1", copies: 1))
    }

    @Test("Cyrillic letters that look like Latin ones are accepted")
    func cyrillicHomoglyphs() {
        #expect(HandwritingRecognizer.matches("ВВВ", expected: "B", copies: 3))
    }

    @Test("The two-digit number 10 is matched as a whole")
    func twoDigitNumber() {
        #expect(HandwritingRecognizer.matches("101010", expected: "10", copies: 3))
        #expect(!HandwritingRecognizer.matches("111", expected: "10", copies: 3))
    }

    @Test("A long text that only contains the letter does not match")
    func tooMuchExtraText() {
        #expect(!HandwritingRecognizer.matches("BANANA", expected: "A", copies: 1))
    }
}
