//
//  LessonProgress.swift
//  LittleLearners
//

import Foundation
import SwiftData

/// Remembers how far the child has got with one learning item (one letter, number or shape).
/// Each child has at most one `LessonProgress` per item.
@Model
final class LessonProgress {
    /// The `id` of the `LearningItem` this progress belongs to, e.g. "en-A".
    var itemID: String

    /// The category saved as text ("letters", "numbers" or "shapes").
    /// SwiftData stores simple text more reliably than enums, so we keep the raw value
    /// and use the `category` property below in the rest of the app.
    var categoryRawValue: String

    /// True once the child has finished this item (for example traced it correctly).
    var isCompleted: Bool

    /// When the child last opened or practised this item.
    var lastPractisedAt: Date

    /// The child this progress belongs to. It is set by adding the record to `ChildProfile.progress`.
    var profile: ChildProfile?

    /// The category as a proper enum value.
    var category: LearningCategory {
        LearningCategory(rawValue: categoryRawValue) ?? .letters
    }

    init(itemID: String, category: LearningCategory, isCompleted: Bool = false, lastPractisedAt: Date = .now) {
        self.itemID = itemID
        self.categoryRawValue = category.rawValue
        self.isCompleted = isCompleted
        self.lastPractisedAt = lastPractisedAt
    }
}
