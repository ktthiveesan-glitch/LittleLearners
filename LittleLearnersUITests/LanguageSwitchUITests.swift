//
//  LanguageSwitchUITests.swift
//  LittleLearnersUITests
//

import XCTest

/// UI tests for changing the app language while the app is running.
final class LanguageSwitchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Picking Tamil on onboarding changes the onboarding text at once.
    @MainActor
    func testOnboardingSwitchesToTamilImmediately() {
        let app = XCUIApplication.launchForTesting()
        XCTAssertTrue(app.staticTexts["What is your name?"].waitForExistence(timeout: 5))

        app.buttons["தமிழ்"].tap()

        XCTAssertTrue(app.staticTexts["உங்கள் பெயர் என்ன?"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["தொடங்குவோம்!"].exists)
        XCTAssertFalse(app.staticTexts["What is your name?"].exists)
    }

    /// Picking Sinhala on onboarding carries over to Home.
    @MainActor
    func testSinhalaChosenOnOnboardingIsUsedOnHome() {
        let app = XCUIApplication.launchForTesting()
        let nameField = app.textFields.firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        app.buttons["සිංහල"].tap()
        nameField.tap()
        nameField.typeText("Nimal\n")
        app.buttons["යමු!"].tap()

        XCTAssertTrue(app.staticTexts["ආයුබෝවන්, Nimal!"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["අකුරු"].exists)
        XCTAssertTrue(app.buttons["ඉලක්කම්"].exists)
    }

    /// Changing the language in the parent area changes the dashboard at once, and Home too.
    @MainActor
    func testParentAreaSwitchesLanguageImmediately() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding()
        app.buttons["Parents"].tap()
        app.typeOnParentalGate(app.parentalGateAnswer())
        XCTAssertTrue(app.navigationBars["Parent area"].waitForExistence(timeout: 5))

        // The language picker is at the bottom of the dashboard.
        app.swipeUp()
        app.swipeUp()
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Language'")).firstMatch.tap()
        app.buttons["සිංහල"].tap()

        // The dashboard is now in Sinhala...
        XCTAssertTrue(app.navigationBars["දෙමාපිය අංශය"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["සැකසුම්"].exists)

        // ...and so is Home.
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.buttons["අකුරු"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["දෙමාපියන්"].exists)
    }
}
