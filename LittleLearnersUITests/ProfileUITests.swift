//
//  ProfileUITests.swift
//  LittleLearnersUITests
//

import XCTest

/// UI tests for multiple child profiles: the profile picker, adding and switching children,
/// separate progress per child, and editing and deleting a child in the parent area.
final class ProfileUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Opens the profile picker from Home by tapping the avatar.
    @MainActor
    private func openProfilePicker(_ app: XCUIApplication) {
        app.buttons["Switch child"].tap()
        XCTAssertTrue(app.staticTexts["Who is learning today?"].waitForExistence(timeout: 5))
    }

    /// Adds another child from the profile picker and waits for their Home screen.
    @MainActor
    private func addChild(_ app: XCUIApplication, name: String) {
        app.buttons["Add child"].tap()
        app.completeOnboarding(name: name)
    }

    /// Opens the parent area and scrolls to the list of children.
    @MainActor
    private func openChildrenList(_ app: XCUIApplication) {
        app.buttons["Parents"].tap()
        app.typeOnParentalGate(app.parentalGateAnswer())
        XCTAssertTrue(app.navigationBars["Parent area"].waitForExistence(timeout: 5))
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Children"].waitForExistence(timeout: 5))
    }

    /// Tapping the avatar on Home shows the picker with the child and the "+" card; tapping the child returns to Home.
    @MainActor
    func testAvatarOnHomeOpensProfilePicker() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding(name: "Nimal")

        openProfilePicker(app)
        XCTAssertTrue(app.buttons["Nimal"].exists)
        XCTAssertTrue(app.buttons["Add child"].exists)

        app.buttons["Nimal"].tap()
        XCTAssertTrue(app.staticTexts["Hi, Nimal!"].waitForExistence(timeout: 5))
    }

    /// A second child can be added from the picker, and the picker switches between the two.
    @MainActor
    func testAddSecondChildAndSwitch() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding(name: "Nimal")

        openProfilePicker(app)
        addChild(app, name: "Kavya")

        openProfilePicker(app)
        XCTAssertTrue(app.buttons["Nimal"].exists)
        XCTAssertTrue(app.buttons["Kavya"].exists)

        app.buttons["Nimal"].tap()
        XCTAssertTrue(app.staticTexts["Hi, Nimal!"].waitForExistence(timeout: 5))
    }

    /// Adding a child can be cancelled, which returns to the picker.
    @MainActor
    func testAddChildCanBeCancelled() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding(name: "Nimal")
        openProfilePicker(app)

        app.buttons["Add child"].tap()
        XCTAssertTrue(app.textFields.firstMatch.waitForExistence(timeout: 5))
        app.swipeUp()
        app.buttons["Cancel"].tap()

        XCTAssertTrue(app.staticTexts["Who is learning today?"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Nimal"].exists)
    }

    /// A star earned by one child does not show for the other child.
    @MainActor
    func testStarsAreSeparatePerChild() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding(name: "Nimal")

        // Nimal traces the letter L correctly and earns a star.
        app.buttons["Letters"].tap()
        app.buttons["L, Lion"].tap()
        app.buttons["Trace it"].tap()
        let canvas = app.otherElements["Trace L"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        func drag(from: CGVector, to: CGVector) {
            canvas.coordinate(withNormalizedOffset: from)
                .press(forDuration: 0.05, thenDragTo: canvas.coordinate(withNormalizedOffset: to))
        }
        drag(from: CGVector(dx: 0.365, dy: 0.17), to: CGVector(dx: 0.365, dy: 0.80))
        drag(from: CGVector(dx: 0.365, dy: 0.805), to: CGVector(dx: 0.67, dy: 0.805))
        app.buttons["Check"].tap()
        XCTAssertTrue(app.staticTexts["Well done!"].waitForExistence(timeout: 10))
        sleep(3) // let the celebration finish
        for _ in 0..<3 {
            app.navigationBars.buttons.firstMatch.tap()
        }
        XCTAssertTrue(app.descendants(matching: .any)["1 star"].waitForExistence(timeout: 5))

        // A new child starts with no stars.
        openProfilePicker(app)
        addChild(app, name: "Kavya")
        XCTAssertTrue(app.descendants(matching: .any)["0 stars"].waitForExistence(timeout: 5))

        // Nimal still has the star.
        openProfilePicker(app)
        app.buttons["Nimal"].tap()
        XCTAssertTrue(app.staticTexts["Hi, Nimal!"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["1 star"].exists)
    }

    /// A parent can change a child's name in the parent area, and Home shows the new name.
    @MainActor
    func testParentCanEditChildName() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding(name: "Nimal")
        openChildrenList(app)

        app.buttons["Nimal"].tap()
        XCTAssertTrue(app.navigationBars["Edit child"].waitForExistence(timeout: 5))
        let nameField = app.textFields.firstMatch
        nameField.tap()
        nameField.typeText(" P")
        app.buttons["Save"].tap()

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Hi, Nimal P!"].waitForExistence(timeout: 5))
    }

    /// Deleting needs a confirmation. Cancelling keeps the child.
    @MainActor
    func testDeleteChildCanBeCancelled() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding(name: "Nimal")
        openChildrenList(app)

        app.buttons["Nimal"].tap()
        app.buttons["Delete child"].tap()
        XCTAssertTrue(app.alerts["Delete Nimal?"].waitForExistence(timeout: 5))
        app.alerts.buttons["Cancel"].tap()

        XCTAssertTrue(app.navigationBars["Edit child"].exists)
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.buttons["Nimal"].waitForExistence(timeout: 5))
    }

    /// Deleting the selected child (with another child left) shows the picker without the deleted child.
    @MainActor
    func testDeleteSelectedChildShowsPicker() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding(name: "Nimal")
        openProfilePicker(app)
        addChild(app, name: "Kavya")
        openChildrenList(app)

        app.buttons["Kavya"].tap()
        app.buttons["Delete child"].tap()
        app.alerts.buttons["Delete"].tap()

        XCTAssertTrue(app.staticTexts["Who is learning today?"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Nimal"].exists)
        XCTAssertFalse(app.buttons["Kavya"].exists)
    }

    /// Deleting the only child goes back to onboarding.
    @MainActor
    func testDeleteLastChildShowsOnboarding() {
        let app = XCUIApplication.launchForTesting()
        app.completeOnboarding(name: "Nimal")
        openChildrenList(app)

        app.buttons["Nimal"].tap()
        app.buttons["Delete child"].tap()
        app.alerts.buttons["Delete"].tap()

        XCTAssertTrue(app.staticTexts["Welcome to Little Learners"].waitForExistence(timeout: 5))
    }
}
