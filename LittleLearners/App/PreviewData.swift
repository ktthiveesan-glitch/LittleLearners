//
//  PreviewData.swift
//  LittleLearners
//

import SwiftData

/// Sample data for Xcode previews only: an in-memory database with one child in it.
/// Screens that need a child use `.modelContainer(PreviewData.container)` and `.environment(PreviewData.profile)`.
enum PreviewData {
    /// A database that lives only in memory, so previews never touch real data.
    static let container: ModelContainer = {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: ChildProfile.self, LessonProgress.self, TracingAttempt.self, EarnedBadge.self,
                                      configurations: configuration)
        } catch {
            fatalError("Could not create the preview database: \(error)")
        }
    }()

    /// A sample child, saved in the preview database.
    static let profile: ChildProfile = {
        let profile = ChildProfile(name: "Nimal", avatar: "🐻", stars: 5)
        container.mainContext.insert(profile)
        return profile
    }()
}
