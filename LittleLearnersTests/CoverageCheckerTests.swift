//
//  CoverageCheckerTests.swift
//  LittleLearnersTests
//

import Testing
import SwiftUI
@testable import LittleLearners

/// Checks the coverage calculation used for Sinhala and Tamil tracing.
/// The guide here is a simple tall rectangle, so the expected results are easy to reason about.
@MainActor
struct CoverageCheckerTests {
    private let canvas = CGSize(width: 300, height: 300)

    /// A guide "letter": a rectangle 100 points wide and 200 tall in the middle of the canvas.
    private let guide = Path(CGRect(x: 100, y: 50, width: 100, height: 200))

    /// A straight vertical line from the top to the bottom of the guide at the given x.
    private func verticalLine(x: CGFloat) -> [CGPoint] {
        [CGPoint(x: x, y: 50), CGPoint(x: x, y: 250)]
    }

    @Test("Drawing over the whole guide passes")
    func fullCoveragePasses() {
        let strokes = [verticalLine(x: 115), verticalLine(x: 150), verticalLine(x: 185)]
        let result = CoverageChecker.check(strokes: strokes, guide: guide, canvasSize: canvas)
        #expect(result.coverage >= 0.95)
        #expect(result.outsideShare == 0)
        #expect(result.isPassing)
    }

    @Test("Drawing over only part of the guide fails")
    func partialCoverageFails() {
        let result = CoverageChecker.check(strokes: [verticalLine(x: 150)], guide: guide, canvasSize: canvas)
        #expect(result.coverage > 0.2)
        #expect(result.coverage < CoverageChecker.requiredCoverage)
        #expect(!result.isPassing)
    }

    @Test("No drawing gives zero coverage")
    func emptyDrawing() {
        let result = CoverageChecker.check(strokes: [], guide: guide, canvasSize: canvas)
        #expect(result.coverage == 0)
        #expect(!result.isPassing)
    }

    @Test("Scribbling over the whole canvas covers the guide but still fails")
    func scribbleFails() {
        // Horizontal lines across the full canvas, 20 points apart.
        let strokes = stride(from: CGFloat(10), through: 290, by: 20).map { y in
            [CGPoint(x: 0, y: y), CGPoint(x: 300, y: y)]
        }
        let result = CoverageChecker.check(strokes: strokes, guide: guide, canvasSize: canvas)
        #expect(result.coverage >= 0.95)
        #expect(result.outsideShare > CoverageChecker.allowedOutsideShare)
        #expect(!result.isPassing)
    }

    @Test("A line far away from the guide covers nothing")
    func drawingElsewhere() {
        let result = CoverageChecker.check(strokes: [verticalLine(x: 20)], guide: guide, canvasSize: canvas)
        #expect(result.coverage == 0)
        #expect(result.outsideShare == 1)
    }

    @Test("A quick stroke with only two points counts the same as a slow one with many")
    func fastAndSlowStrokesMatch() {
        let fast = [verticalLine(x: 150)]
        let slow = [stride(from: CGFloat(50), through: 250, by: 2).map { CGPoint(x: 150, y: $0) }]
        let fastResult = CoverageChecker.check(strokes: fast, guide: guide, canvasSize: canvas)
        let slowResult = CoverageChecker.check(strokes: slow, guide: guide, canvasSize: canvas)
        #expect(abs(fastResult.coverage - slowResult.coverage) < 0.02)
    }

    @Test("Every letter and number has a guide outline that fits inside the canvas")
    func guideExistsForEveryCharacter() {
        let items = LearningContent.englishLetters + LearningContent.sinhalaVowels
            + LearningContent.tamilVowels + LearningContent.numbers
        for item in items {
            let path = GuidePathBuilder.path(for: item.character, in: canvas)
            #expect(!path.isEmpty, "No guide for \(item.id)")
            #expect(CGRect(origin: .zero, size: canvas).insetBy(dx: -1, dy: -1).contains(path.boundingRect),
                    "Guide for \(item.id) is outside the canvas")
        }
    }
}
