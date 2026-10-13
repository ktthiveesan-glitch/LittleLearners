//
//  CoverageChecker.swift
//  LittleLearners
//

import SwiftUI

/// The outcome of a coverage check.
struct CoverageResult {
    /// How much of the guide character the drawing covers, from 0.0 to 1.0.
    let coverage: Double
    /// How much of the drawing lies away from the guide, from 0.0 to 1.0.
    let outsideShare: Double

    /// A tracing passes when it covers at least 70% of the guide
    /// and no more than 40% of it is scribbled outside the guide.
    var isPassing: Bool {
        coverage >= CoverageChecker.requiredCoverage && outsideShare <= CoverageChecker.allowedOutsideShare
    }
}

/// Checks a tracing by geometry instead of machine learning.
///
/// Why this exists: Apple's Vision text recognition cannot read Sinhala or Tamil script,
/// so for those letters we cannot ask "which letter is this?". Instead we ask
/// "did the child draw over most of the guide letter?". This only proves the child followed
/// the guide; it cannot tell a neat letter from a careful colouring-in of the same shape.
enum CoverageChecker {
    /// The drawing must cover at least this much of the guide.
    static let requiredCoverage = 0.7
    /// At most this much of the drawing may be outside the guide. Stops "scribble over everything" from passing.
    static let allowedOutsideShare = 0.4

    /// Compares the child's strokes with the guide outline.
    ///
    /// How it works:
    /// 1. Lay a grid of dots over the canvas and keep the dots that fall inside the guide character.
    /// 2. Turn the strokes into a dense list of points.
    /// 3. A guide dot is "covered" when a drawn point is close to it. Coverage = covered dots ÷ all dots.
    /// 4. A drawn point is "outside" when no guide dot is close to it.
    static func check(strokes: [[CGPoint]], guide: Path, canvasSize: CGSize) -> CoverageResult {
        let side = min(canvasSize.width, canvasSize.height)
        guard side > 0 else { return CoverageResult(coverage: 0, outsideShare: 0) }

        let spacing = side / 40      // gap between grid dots
        let reach = side * 0.06      // how close counts as "covered" (about the width of a finger stroke)

        let guideDots = gridDots(inside: guide, spacing: spacing)
        let drawnPoints = densePoints(from: strokes, spacing: spacing)
        guard !guideDots.isEmpty, !drawnPoints.isEmpty else { return CoverageResult(coverage: 0, outsideShare: 0) }

        let coveredCount = guideDots.filter { isNear($0, anyOf: drawnPoints, within: reach) }.count
        let outsideCount = drawnPoints.filter { !isNear($0, anyOf: guideDots, within: reach) }.count

        return CoverageResult(coverage: Double(coveredCount) / Double(guideDots.count),
                              outsideShare: Double(outsideCount) / Double(drawnPoints.count))
    }

    /// Returns the grid dots that lie inside the guide character.
    private static func gridDots(inside guide: Path, spacing: CGFloat) -> [CGPoint] {
        let bounds = guide.boundingRect
        guard !bounds.isEmpty else { return [] }
        var dots: [CGPoint] = []
        for x in stride(from: bounds.minX, through: bounds.maxX, by: spacing) {
            for y in stride(from: bounds.minY, through: bounds.maxY, by: spacing) {
                let dot = CGPoint(x: x, y: y)
                if guide.contains(dot) {
                    dots.append(dot)
                }
            }
        }
        return dots
    }

    /// A fast finger leaves big gaps between recorded points, so this adds extra points
    /// along each line segment until no two neighbours are further apart than `spacing`.
    private static func densePoints(from strokes: [[CGPoint]], spacing: CGFloat) -> [CGPoint] {
        var points: [CGPoint] = []
        for stroke in strokes {
            guard var previous = stroke.first else { continue }
            points.append(previous)
            for point in stroke.dropFirst() {
                let steps = max(1, Int(distance(previous, point) / spacing))
                for step in 1...steps {
                    let fraction = CGFloat(step) / CGFloat(steps)
                    points.append(CGPoint(x: previous.x + (point.x - previous.x) * fraction,
                                          y: previous.y + (point.y - previous.y) * fraction))
                }
                previous = point
            }
        }
        return points
    }

    /// True if any of `others` is within `reach` of `point`.
    private static func isNear(_ point: CGPoint, anyOf others: [CGPoint], within reach: CGFloat) -> Bool {
        others.contains { distance(point, $0) <= reach }
    }

    /// Straight-line distance between two points.
    private static func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }
}
