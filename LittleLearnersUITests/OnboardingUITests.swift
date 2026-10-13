//
//  OnboardingUITests.swift
//  LittleLearnersUITests
//

import XCTest

/// UI tests for the onboarding flow.
final class OnboardingUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// The start button must stay disabled until a name is typed.
    @MainActor
    func testStartButtonNeedsAName() {
        let app = XCUIApplication.launchForTesting()
        let startButton = app.buttons["Let's go!"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        XCTAssertFalse(startButton.isEnabled)

        let nameField = app.textFields.firstMatch
        nameField.tap()
        nameField.typeText("Nimal\n")
        XCTAssertTrue(startButton.isEnabled)
    }

    /// Typing a name, picking an avatar and tapping the button leads to Home with a greeting.
    @MainActor
    func testOnboardingLeadsToHome() {
        let app = XCUIApplication.launchForTesting()
        XCTAssertTrue(app.staticTexts["Welcome to Little Learners"].waitForExistence(timeout: 5))

        let nameField = app.textFields.firstMatch
        nameField.tap()
        nameField.typeText("Nimal\n")
        app.buttons["🦁"].tap()
        XCTAssertTrue(app.buttons["🦁"].isSelected)
        app.buttons["Let's go!"].tap()

        XCTAssertTrue(app.staticTexts["Hi, Nimal!"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Letters"].exists)
        XCTAssertTrue(app.buttons["Numbers"].exists)
        XCTAssertTrue(app.buttons["Shapes"].exists)
    }
}
