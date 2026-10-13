//
//  NavigationUITests.swift
//  LittleLearnersUITests
//

import XCTest

/// UI tests for moving through the main learning screens.
final class NavigationUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Home → Letters → Lesson → Tracing, and back to Home.
    @MainActor
    func testHomeToLettersToLessonToTracing() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding()

        // Home → Letters grid.
        app.buttons["Letters"].tap()
        XCTAssertTrue(app.navigationBars["Letters"].waitForExistence(timeout: 5))

        // Grid → Lesson for A.
        app.buttons["A, Apple"].tap()
        XCTAssertTrue(app.staticTexts["Apple"].waitForExistence(timeout: 5))

        // The Next button moves to B; the Previous button goes back to A.
        app.buttons["Next"].tap()
        XCTAssertTrue(app.staticTexts["Ball"].waitForExistence(timeout: 5))
        app.buttons["Previous"].tap()
        XCTAssertTrue(app.staticTexts["Apple"].waitForExistence(timeout: 5))

        // Lesson → Tracing.
        app.buttons["Trace it"].tap()
        XCTAssertTrue(app.navigationBars["Trace A"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["Trace A"].exists)
        XCTAssertFalse(app.buttons["Check"].isEnabled, "Check must be disabled before anything is drawn")

        // Back three times returns to Home.
        for _ in 0..<3 {
            app.navigationBars.buttons.firstMatch.tap()
        }
        XCTAssertTrue(app.staticTexts["Hi, Nimal!"].waitForExistence(timeout: 5))
    }

    /// Swiping left on the lesson shows the next letter.
    @MainActor
    func testSwipeShowsNextLetter() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding()
        app.buttons["Letters"].tap()
        app.buttons["A, Apple"].tap()
        XCTAssertTrue(app.staticTexts["Apple"].waitForExistence(timeout: 5))

        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["Ball"].waitForExistence(timeout: 5))
    }

    /// A drawing that does not follow the letter gets the friendly "Try again!" message.
    @MainActor
    func testWrongTracingShowsTryAgain() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding()
        app.buttons["Letters"].tap()
        app.buttons["A, Apple"].tap()
        app.buttons["Trace it"].tap()

        let canvas = app.otherElements["Trace A"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        // One short line in a corner: not an "A".
        let start = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.9))
        let end = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.9))
        start.press(forDuration: 0.1, thenDragTo: end)

        app.buttons["Check"].tap()
        XCTAssertTrue(app.staticTexts["Try again!"].waitForExistence(timeout: 10))
    }
}
