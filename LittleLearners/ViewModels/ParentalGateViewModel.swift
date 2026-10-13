//
//  ParentalGateViewModel.swift
//  LittleLearners
//

import Foundation

/// The logic of the parental gate: it asks a sum that an adult can do but a young child cannot,
/// collects the typed answer and unlocks the parent area only when the answer is right.
@Observable
final class ParentalGateViewModel {
    /// The two numbers in the question, e.g. 7 and 5 for "7 + 5".
    private(set) var firstNumber: Int
    private(set) var secondNumber: Int

    /// The digits typed so far, e.g. "12".
    private(set) var typedAnswer = ""

    /// Becomes true after a correct answer. The parent area shows the dashboard when this is true.
    private(set) var isUnlocked = false

    /// How many wrong answers so far. The view shakes each time this goes up.
    private(set) var wrongCount = 0

    /// Creates a gate with a random question. Tests can pass fixed numbers instead.
    init(firstNumber: Int = .random(in: 6...9), secondNumber: Int = .random(in: 6...9)) {
        self.firstNumber = firstNumber
        self.secondNumber = secondNumber
    }

    /// The right answer to the question.
    var correctAnswer: Int {
        firstNumber + secondNumber
    }

    /// OK can only be tapped once something is typed.
    var canSubmit: Bool {
        !typedAnswer.isEmpty
    }

    /// Adds one digit to the answer. The answer is never longer than two digits.
    func typeDigit(_ digit: Int) {
        guard typedAnswer.count < 2 else { return }
        typedAnswer += String(digit)
    }

    /// Removes the last typed digit.
    func deleteLastDigit() {
        if !typedAnswer.isEmpty {
            typedAnswer.removeLast()
        }
    }

    /// Checks the typed answer. Right: unlock. Wrong: count it, clear the answer and ask a new question,
    /// so a child cannot get in by trying every number for the same sum.
    func submit() {
        guard canSubmit else { return }
        if Int(typedAnswer) == correctAnswer {
            isUnlocked = true
        } else {
            wrongCount += 1
            typedAnswer = ""
            firstNumber = .random(in: 6...9)
            secondNumber = .random(in: 6...9)
        }
    }
}
