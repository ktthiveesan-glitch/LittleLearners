//
//  TestSupport.swift
//  LittleLearnersTests
//

import Foundation
import SwiftData
@testable import LittleLearners

/// Helpers shared by the unit tests.
@MainActor
enum TestSupport {
    /// Makes an empty database that lives only in memory, so tests never touch real data
    /// and every test starts clean.
    static func makeContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: ChildProfile.self, LessonProgress.self, TracingAttempt.self, EarnedBadge.self,
                                  configurations: configuration)
    }
}
