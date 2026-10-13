//
//  TracingAttempt.swift
//  LittleLearners
//

import Foundation
import SwiftData

/// One try at tracing a character. A new `TracingAttempt` is saved every time the child taps Check.
/// The parent area uses these to show recent activity and charts.
@Model
final class TracingAttempt {
    /// The `id` of the `LearningItem` that was traced, e.g. "en-A".
    var itemID: String

    /// The character the child was asked to trace, e.g. "A".
    var character: String

    /// True if the tracing was judged correct.
    var isCorrect: Bool

    /// How good the tracing was, from 0.0 (nothing matched) to 1.0 (perfect).
    var score: Double

    /// When the attempt was made.
    var date: Date

    /// The child who made the attempt. It is set by adding the attempt to `ChildProfile.attempts`.
    var profile: ChildProfile?

    init(itemID: String, character: String, isCorrect: Bool, score: Double, date: Date = .now) {
        self.itemID = itemID
        self.character = character
        self.isCorrect = isCorrect
        self.score = score
        self.date = date
    }
}
