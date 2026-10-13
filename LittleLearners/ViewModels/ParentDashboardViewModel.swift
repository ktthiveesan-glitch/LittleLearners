//
//  ParentDashboardViewModel.swift
//  LittleLearners
//

import Foundation
import SwiftData

/// The number of stars earned on one day. One bar in the "stars per day" chart.
struct DailyStars: Identifiable {
    /// The start (midnight) of the day.
    let date: Date
    let stars: Int
    var id: Date { date }
}

/// How many items of one category the child has completed. One bar in the progress chart.
struct CategoryProgress: Identifiable {
    let category: LearningCategory
    let completed: Int
    let total: Int
    var id: LearningCategory { category }

    /// Completed share from 0.0 to 1.0.
    var fraction: Double {
        total == 0 ? 0 : Double(completed) / Double(total)
    }
}

/// Turns the saved records into the numbers the parent dashboard shows, and resets progress.
/// The functions take plain arrays, so they are easy to test without a database.
@Observable
final class ParentDashboardViewModel {
    /// How many recent tracing attempts the list shows.
    static let recentAttemptLimit = 10

    /// How many days the stars chart shows.
    static let chartDayCount = 7

    /// The fetch for one child's "recent tracing" list: newest first and at most ten records.
    /// The limit is part of the fetch, so the database never loads the child's whole history.
    static func recentAttemptsDescriptor(for profileID: UUID) -> FetchDescriptor<TracingAttempt> {
        var descriptor = FetchDescriptor<TracingAttempt>(
            predicate: #Predicate { $0.profile?.profileID == profileID },
            sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = recentAttemptLimit
        return descriptor
    }

    /// The fetch for one child's stars chart: only their attempts from the first chart day onwards.
    static func chartAttemptsDescriptor(for profileID: UUID, from chartStart: Date) -> FetchDescriptor<TracingAttempt> {
        FetchDescriptor<TracingAttempt>(
            predicate: #Predicate { $0.profile?.profileID == profileID && $0.date >= chartStart })
    }

    /// The start of the oldest day on the stars chart. The dashboard only fetches attempts from this moment on.
    static func chartStartDate(today: Date = .now, calendar: Calendar = .current) -> Date {
        let startOfToday = calendar.startOfDay(for: today)
        return calendar.date(byAdding: .day, value: -(chartDayCount - 1), to: startOfToday) ?? startOfToday
    }

    /// Stars earned on each of the last 7 days, oldest first, ending today.
    /// A star is earned by each correct tracing attempt, so we count those per day.
    func dailyStars(from attempts: [TracingAttempt], today: Date = .now, calendar: Calendar = .current) -> [DailyStars] {
        // Go through the attempts once and count the correct ones for each day.
        var starsByDay: [Date: Int] = [:]
        for attempt in attempts where attempt.isCorrect {
            starsByDay[calendar.startOfDay(for: attempt.date), default: 0] += 1
        }

        let startOfToday = calendar.startOfDay(for: today)
        return (0..<Self.chartDayCount).reversed().compactMap { daysAgo in
            guard let day = calendar.date(byAdding: .day, value: -daysAgo, to: startOfToday) else { return nil }
            return DailyStars(date: day, stars: starsByDay[day] ?? 0)
        }
    }

    /// For each category: how many items are completed out of how many exist.
    func categoryProgress(from progress: [LessonProgress]) -> [CategoryProgress] {
        LearningCategory.allCases.map { category in
            let completed = progress.filter { $0.isCompleted && $0.category == category }.count
            return CategoryProgress(category: category, completed: completed, total: totalItems(in: category))
        }
    }

    /// The number of items in a category. Letters counts all three scripts together.
    private func totalItems(in category: LearningCategory) -> Int {
        switch category {
        case .letters: Script.allCases.map { LearningContent.letters(for: $0).count }.reduce(0, +)
        case .numbers: LearningContent.numbers.count
        case .shapes: LearningContent.shapes.count
        }
    }

    /// Deletes one child's progress. Their name and avatar are kept.
    func resetProgress(of profile: ChildProfile, in context: ModelContext) {
        ProgressService.resetAll(for: profile, in: context)
    }
}
