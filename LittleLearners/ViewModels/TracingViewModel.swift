//
//  TracingViewModel.swift
//  LittleLearners
//

import SwiftUI
import SwiftData

/// Holds the child's drawing for one character, checks it, saves the attempt
/// and awards a star when it is correct.
@Observable
final class TracingViewModel {
    /// Where the tracing screen is in its flow.
    enum Status {
        /// The child is drawing (nothing checked yet, or the canvas was cleared).
        case drawing
        /// The recognizer is working.
        case checking
        /// The last check was correct.
        case correct
        /// The last check was wrong.
        case wrong
    }

    /// The letter or number being traced.
    let item: LearningItem

    /// The child's drawing: a list of strokes, each a list of points.
    /// Points are fractions of the canvas (0.0 to 1.0), so they stay valid when the canvas changes size.
    var strokes: [[CGPoint]] = [] {
        didSet {
            // Only change `hasDrawing` when it really flips, so views that read it are not redrawn for every point.
            let hasDrawingNow = !strokes.isEmpty
            if hasDrawingNow != hasDrawing {
                hasDrawing = hasDrawingNow
            }
        }
    }

    /// True when at least one stroke is drawn. The tracing screen reads this instead of `strokes`,
    /// so its buttons and message are not redrawn each time the finger moves; only the canvas is.
    private(set) var hasDrawing = false

    /// The current state of the screen.
    private(set) var status: Status = .drawing

    /// How many wrong answers so far. The view shakes the canvas each time this goes up.
    private(set) var wrongCount = 0

    /// The dotted outline of the character, sized for the canvas.
    private(set) var guidePath = Path()

    /// The size of the drawing area, reported by the view.
    private var canvasSize: CGSize = .zero

    /// Does the actual checking (Vision or coverage).
    private let recognizer = HandwritingRecognizer()

    init(item: LearningItem) {
        self.item = item
    }

    /// Thickness of the child's line: 5% of the canvas, so it looks the same on iPhone and iPad.
    var lineWidth: CGFloat {
        min(canvasSize.width, canvasSize.height) * 0.05
    }

    /// Check is only possible when something is drawn and no check is running or already passed.
    var canCheck: Bool {
        hasDrawing && status != .checking && status != .correct
    }

    /// Called when the canvas gets its size (first layout or rotation). The guide is rebuilt for the new size.
    func canvasSizeChanged(to size: CGSize) {
        canvasSize = size
        guidePath = GuidePathBuilder.path(for: item.character, in: size)
    }

    /// Adds one finger position to the drawing: as the start of a new stroke, or at the end of the current one.
    func addPoint(_ point: CGPoint, startsNewStroke: Bool) {
        if startsNewStroke || strokes.isEmpty {
            strokes.append([point])
        } else {
            strokes[strokes.count - 1].append(point)
        }
    }

    /// Wipes the drawing so the child can start again.
    func clear() {
        strokes = []
        status = .drawing
    }

    /// Checks the drawing and saves a `TracingAttempt` for the given child. If it is correct, that child
    /// gets a star, the item is marked as completed for them, and any newly won badges are saved.
    func check(profile: ChildProfile) async {
        guard canCheck else { return }
        status = .checking

        // Turn the fractions back into real canvas points for the recognizer.
        let size = canvasSize
        let canvasStrokes = strokes.map { stroke in
            stroke.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
        }
        let result = await recognizer.check(strokes: canvasStrokes, guide: guidePath, canvasSize: canvasSize,
                                            lineWidth: lineWidth, item: item)

        // Adding the attempt to the child's list links it to that child and saves it.
        profile.attempts.append(TracingAttempt(itemID: item.id, character: item.character,
                                               isCorrect: result.isCorrect, score: result.score))
        if result.isCorrect {
            profile.stars += 1
            ProgressService.markCompleted(item, for: profile)
            BadgeService.awardNewBadges(for: profile)
            status = .correct
        } else {
            wrongCount += 1
            status = .wrong
        }
        // Save now, so the attempt and the star are on disk even if the app is closed straight away.
        try? profile.modelContext?.save()
    }
}
