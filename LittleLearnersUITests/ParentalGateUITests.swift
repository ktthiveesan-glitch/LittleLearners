//
//  ParentalGateUITests.swift
//  LittleLearnersUITests
//

import XCTest

/// UI tests for the parental gate in front of the parent area.
final class ParentalGateUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// A wrong answer must not open the parent area.
    @MainActor
    func testWrongAnswerKeepsParentAreaLocked() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding()
        app.buttons["Parents"].tap()

        let wrongAnswer = app.parentalGateAnswer() + 1
        app.typeOnParentalGate(wrongAnswer)

        // Still on the gate: the question is there and the dashboard is not.
        XCTAssertTrue(app.staticTexts["Parents only"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.navigationBars["Parent area"].exists)
        XCTAssertFalse(app.staticTexts["Recent tracing"].exists)
    }

    /// The correct answer opens the dashboard.
    @MainActor
    func testCorrectAnswerOpensParentArea() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding()
        app.buttons["Parents"].tap()

        app.typeOnParentalGate(app.parentalGateAnswer())

        XCTAssertTrue(app.navigationBars["Parent area"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Parents only"].exists)
    }

    /// After a wrong answer, the next (new) question can still be answered correctly.
    @MainActor
    func testCorrectAnswerAfterWrongAnswer() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding()
        app.buttons["Parents"].tap()

        app.typeOnParentalGate(app.parentalGateAnswer() + 1)
        XCTAssertFalse(app.navigationBars["Parent area"].exists)

        app.typeOnParentalGate(app.parentalGateAnswer())
        XCTAssertTrue(app.navigationBars["Parent area"].waitForExistence(timeout: 5))
    }
}
