//
//  LaunchPerformanceTests.swift
//  LittleLearnersUITests
//

import XCTest

/// Measures how long the app takes to launch.
final class LaunchPerformanceTests: XCTestCase {
    /// Launches the app several times and records the launch time.
    /// The result (average and spread) is shown in Xcode's test report.
    @MainActor
    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
