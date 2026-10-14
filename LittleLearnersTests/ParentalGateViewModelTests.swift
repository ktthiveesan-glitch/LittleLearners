//
//  ParentalGateViewModelTests.swift
//  LittleLearnersTests
//

import Testing
@testable import LittleLearners

/// Checks the parental gate: only the right answer to the sum unlocks the parent area.
@MainActor
struct ParentalGateViewModelTests {
    /// Types a whole number, one digit at a time, like a person tapping the keypad.
    private func type(_ number: Int, into gate: ParentalGateViewModel) {
        for character in String(number) {
            gate.typeDigit(Int(String(character)) ?? 0)
        }
    }

    @Test("The correct answer unlocks the gate")
    func correctAnswerUnlocks() {
        let gate = ParentalGateViewModel(firstNumber: 7, secondNumber: 5)
        type(12, into: gate)
        gate.submit()
        #expect(gate.isUnlocked)
        #expect(gate.wrongCount == 0)
    }

    @Test("A wrong answer keeps the gate locked, counts the mistake and clears the answer")
    func wrongAnswerStaysLocked() {
        let gate = ParentalGateViewModel(firstNumber: 7, secondNumber: 5)
        type(13, into: gate)
        gate.submit()
        #expect(!gate.isUnlocked)
        #expect(gate.wrongCount == 1)
        #expect(gate.typedAnswer.isEmpty)
    }

    @Test("After a wrong answer the new question can still be answered correctly")
    func canRecoverAfterWrongAnswer() {
        let gate = ParentalGateViewModel(firstNumber: 7, secondNumber: 5)
        type(99, into: gate)
        gate.submit()
        type(gate.correctAnswer, into: gate)
        gate.submit()
        #expect(gate.isUnlocked)
    }

    @Test("Random questions always use numbers from 6 to 9, so the answer has two digits")
    func randomQuestionRange() {
        for _ in 0..<50 {
            let gate = ParentalGateViewModel()
            #expect((6...9).contains(gate.firstNumber))
            #expect((6...9).contains(gate.secondNumber))
            #expect(gate.correctAnswer >= 12)
        }
    }

    @Test("The answer is never longer than two digits")
    func answerLengthLimit() {
        let gate = ParentalGateViewModel(firstNumber: 7, secondNumber: 5)
        type(123, into: gate)
        #expect(gate.typedAnswer == "12")
    }

    @Test("Delete removes the last digit and does nothing when empty")
    func deleteDigit() {
        let gate = ParentalGateViewModel(firstNumber: 7, secondNumber: 5)
        gate.deleteLastDigit()
        #expect(gate.typedAnswer.isEmpty)
        type(12, into: gate)
        gate.deleteLastDigit()
        #expect(gate.typedAnswer == "1")
    }

    @Test("Submitting with nothing typed does nothing")
    func emptySubmit() {
        let gate = ParentalGateViewModel(firstNumber: 7, secondNumber: 5)
        #expect(!gate.canSubmit)
        gate.submit()
        #expect(!gate.isUnlocked)
        #expect(gate.wrongCount == 0)
    }
}
 
