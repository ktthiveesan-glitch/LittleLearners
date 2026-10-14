//
//  ParentDashboardViewModelTests.swift
//  LittleLearnersTests
//

import Testing
import Foundation
import SwiftData
@testable import LittleLearners

/// Tests for the numbers shown on the parent dashboard and for reset progress.
@MainActor
struct ParentDashboardViewModelTests {
    private let viewModel = ParentDashboardViewModel()
    private let calendar = Calendar.current

    /// A fixed "today" (midday), so the tests give the same result on any day.
    private var today: Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 12)) ?? .now
    }

    /// Makes an attempt that happened the given number of days before `today`.
    private func attempt(daysAgo: Int, isCorrect: Bool) -> TracingAttempt {
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
        return TracingAttempt(itemID: "en-A", character: "A", isCorrect: isCorrect, score: isCorrect ? 1 : 0, date: date)
    }

    @Test("Stars per day covers exactly the last 7 days, oldest first, ending today")
    func sevenDays() {
        let days = viewModel.dailyStars(from: [], today: today, calendar: calendar)
        #expect(days.count == 7)
        #expect(days.last?.date == calendar.startOfDay(for: today))
        #expect(days.map(\.date) == days.map(\.date).sorted())
        #expect(days.allSatisfy { $0.stars == 0 })
    }

    @Test("Only correct attempts count as stars, on the day they happened")
    func starsAreCountedPerDay() {
        let attempts = [
            attempt(daysAgo: 0, isCorrect: true),
            attempt(daysAgo: 0, isCorrect: true),
            attempt(daysAgo: 0, isCorrect: false),
            attempt(daysAgo: 3, isCorrect: true),
            attempt(daysAgo: 10, isCorrect: true), // older than 7 days: not shown
        ]
        let days = viewModel.dailyStars(from: attempts, today: today, calendar: calendar)
        #expect(days[6].stars == 2)
        #expect(days[3].stars == 1)
        #expect(days.map(\.stars).reduce(0, +) == 3)
    }

    @Test("Progress per category counts completed items against the total")
    func categoryProgress() {
        let records = [
            LessonProgress(itemID: "en-A", category: .letters, isCompleted: true),
            LessonProgress(itemID: "ta-அ", category: .letters, isCompleted: true),
            LessonProgress(itemID: "num-1", category: .numbers, isCompleted: true),
            LessonProgress(itemID: "shape-circle", category: .shapes, isCompleted: false),
        ]
        let progress = viewModel.categoryProgress(from: records)
        #expect(progress.map(\.category) == [.letters, .numbers, .shapes])
        #expect(progress.map(\.completed) == [2, 1, 0])
        #expect(progress.map(\.total) == [52, 10, 6])
        #expect(progress[1].fraction == 0.1)
    }

    @Test("The recent attempts fetch returns one child's ten newest, newest first")
    func recentAttemptsFetch() throws {
        let container = try TestSupport.makeContainer()
        let nimal = ChildProfile(name: "Nimal", avatar: "🐻")
        let kavya = ChildProfile(name: "Kavya", avatar: "🐱")
        container.mainContext.insert(nimal)
        container.mainContext.insert(kavya)
        for item in (0..<15).map({ attempt(daysAgo: $0, isCorrect: true) }).shuffled() {
            nimal.attempts.append(item)
        }
        kavya.attempts.append(attempt(daysAgo: 0, isCorrect: false))

        let descriptor = ParentDashboardViewModel.recentAttemptsDescriptor(for: nimal.profileID)
        let recent = try container.mainContext.fetch(descriptor)
        #expect(recent.count == 10)
        #expect(recent.map(\.date) == recent.map(\.date).sorted(by: >))
        #expect(recent.first?.date == today)
        #expect(recent.allSatisfy { $0.profile === nimal })
    }

    @Test("The chart fetch returns only one child's attempts from the last 7 days")
    func chartAttemptsFetch() throws {
        let container = try TestSupport.makeContainer()
        let nimal = ChildProfile(name: "Nimal", avatar: "🐻")
        let kavya = ChildProfile(name: "Kavya", avatar: "🐱")
        container.mainContext.insert(nimal)
        container.mainContext.insert(kavya)
        nimal.attempts.append(attempt(daysAgo: 0, isCorrect: true))
        nimal.attempts.append(attempt(daysAgo: 6, isCorrect: true))
        nimal.attempts.append(attempt(daysAgo: 8, isCorrect: true))   // too old for the chart
        kavya.attempts.append(attempt(daysAgo: 1, isCorrect: true))   // another child

        let start = ParentDashboardViewModel.chartStartDate(today: today, calendar: calendar)
        let descriptor = ParentDashboardViewModel.chartAttemptsDescriptor(for: nimal.profileID, from: start)
        let found = try container.mainContext.fetch(descriptor)
        #expect(found.count == 2)
        #expect(found.allSatisfy { $0.profile === nimal })
    }

    @Test("The stars chart starts six days before today, at midnight")
    func chartStart() {
        let start = ParentDashboardViewModel.chartStartDate(today: today, calendar: calendar)
        let days = viewModel.dailyStars(from: [], today: today, calendar: calendar)
        #expect(start == days.first?.date)
    }

    @Test("Reset deletes one child's attempts, progress and badges, sets stars to zero and keeps the profile")
    func resetProgress() throws {
        let container = try TestSupport.makeContainer()
        let context = container.mainContext
        let nimal = ChildProfile(name: "Nimal", avatar: "🐻", stars: 7)
        let kavya = ChildProfile(name: "Kavya", avatar: "🐱", stars: 3)
        context.insert(nimal)
        context.insert(kavya)
        for child in [nimal, kavya] {
            child.attempts.append(attempt(daysAgo: 0, isCorrect: true))
            child.progress.append(LessonProgress(itemID: "en-A", category: .letters, isCompleted: true))
            child.badges.append(EarnedBadge(badgeID: Badge.firstStar.id))
        }

        viewModel.resetProgress(of: nimal, in: context)
        try context.save()

        // Nimal's progress is gone, but the profile stays.
        #expect(nimal.attempts.isEmpty)
        #expect(nimal.progress.isEmpty)
        #expect(nimal.badges.isEmpty)
        #expect(nimal.stars == 0)
        #expect(nimal.name == "Nimal")

        // The other child is untouched.
        #expect(kavya.stars == 3)
        #expect(kavya.attempts.count == 1)
        #expect(kavya.progress.count == 1)
        #expect(kavya.badges.count == 1)
        #expect(try context.fetch(FetchDescriptor<ChildProfile>()).count == 2)
        #expect(try context.fetch(FetchDescriptor<TracingAttempt>()).count == 1)
    }
}
