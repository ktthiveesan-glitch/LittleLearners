//
//  ProgressService.swift
//  LittleLearners
//

import Foundation
import SwiftData

/// Records which learning items a child has finished, and can wipe a child's progress.
enum ProgressService {
    /// Deletes one child's tracing attempts, progress records and badges, and sets their stars back to zero.
    /// The profile itself (name and avatar) is kept, and other children are not touched.
    static func resetAll(for profile: ChildProfile, in context: ModelContext) {
        // Deleting a record also takes it out of the child's list, so loop over a copy of each list.
        for attempt in Array(profile.attempts) { context.delete(attempt) }
        for record in Array(profile.progress) { context.delete(record) }
        for badge in Array(profile.badges) { context.delete(badge) }
        profile.stars = 0
    }

    /// Marks one item (a letter, number or shape) as completed for this child.
    /// If the child already has a record for the item it is updated; otherwise a new one is added,
    /// so a child never has more than one record per item.
    static func markCompleted(_ item: LearningItem, for profile: ChildProfile) {
        if let existing = profile.progress.first(where: { $0.itemID == item.id }) {
            existing.isCompleted = true
            existing.lastPractisedAt = .now
        } else {
            // Adding to the child's list links the record to the child and saves it.
            profile.progress.append(LessonProgress(itemID: item.id, category: item.category, isCompleted: true))
        }
    }
}
