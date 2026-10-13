//
//  UITestHelpers.swift
//  LittleLearnersUITests
//

import XCTest

/// Steps that several UI tests share.
extension XCUIApplication {
    /// Starts the app in UI-testing mode: no saved data and English as the language,
    /// so every test begins on the onboarding screen. The device is put in portrait first,
    /// because the tests expect the portrait layouts.
    @MainActor
    static func launchForTesting() -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
        return app
    }

    /// Fills in the onboarding screen and waits for Home.
    @MainActor
    func completeOnboarding(name: String = "Nimal") {
        let nameField = textFields.firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "Onboarding did not appear")
        nameField.tap()
        nameField.typeText(name + "\n")
        buttons["Let's go!"].tap()
        XCTAssertTrue(staticTexts["Hi, \(name)!"].waitForExistence(timeout: 5), "Home did not appear")
    }

    /// Reads the sum on the parental gate (for example "What is 7 + 5?") and returns the right answer.
    @MainActor
    func parentalGateAnswer() -> Int {
        let question = staticTexts.matching(NSPredicate(format: "label CONTAINS '+'")).firstMatch
        XCTAssertTrue(question.waitForExistence(timeout: 5), "The gate question did not appear")
        let numbers = question.label.split(whereSeparator: { !$0.isNumber }).compactMap { Int($0) }
        return numbers.reduce(0, +)
    }

    /// Types a number on the gate's keypad and taps OK.
    @MainActor
    func typeOnParentalGate(_ number: Int) {
        for digit in String(number) {
            buttons[String(digit)].tap()
        }
        buttons["OK"].tap()
    }
}
