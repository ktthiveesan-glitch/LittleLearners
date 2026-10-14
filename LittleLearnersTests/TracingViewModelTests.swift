//
//  TracingViewModelTests.swift
//  LittleLearnersTests
//

import Testing
import SwiftUI
import SwiftData
@testable import LittleLearners

/// Tests for the tracing view model. They use a Tamil letter, which is checked by coverage,
/// so the result does not depend on what Vision can read.
@MainActor
struct TracingViewModelTests {
    private let canvas = CGSize(width: 300, height: 300)
    private let container: ModelContainer
    private let profile: ChildProfile
    private let viewModel: TracingViewModel

    init() throws {
        container = try TestSupport.makeContainer()
        profile = ChildProfile(name: "Test", avatar: "🐻")
        container.mainContext.insert(profile)
        viewModel = TracingViewModel(item: LearningContent.tamilVowels[0])
        viewModel.canvasSizeChanged(to: canvas)
    }

    /// A "perfect" drawing: a dot on every part of the guide letter.
    /// Points are fractions of the canvas, as the real canvas stores them.
    private func perfectStrokes() -> [[CGPoint]] {
        var strokes: [[CGPoint]] = []
        for x in stride(from: CGFloat(0), through: canvas.width, by: 8) {
            for y in stride(from: CGFloat(0), through: canvas.height, by: 8)
            where viewModel.guidePath.contains(CGPoint(x: x, y: y)) {
                strokes.append([CGPoint(x: x / canvas.width, y: y / canvas.height)])
            }
        }
        return strokes
    }

    @Test("Check is not possible until something is drawn")
    func cannotCheckEmptyCanvas() {
        #expect(!viewModel.canCheck)
        viewModel.strokes = [[CGPoint(x: 0.5, y: 0.5)]]
        #expect(viewModel.canCheck)
    }

    @Test("The guide outline is built when the canvas gets its size")
    func guideIsBuilt() {
        #expect(!viewModel.guidePath.isEmpty)
        #expect(viewModel.lineWidth == 15)
    }

    @Test("A correct tracing gives a star, saves the attempt, marks progress and wins the first badge")
    func correctTracing() async throws {
        viewModel.strokes = perfectStrokes()
        await viewModel.check(profile: profile)

        #expect(viewModel.status == .correct)
        #expect(profile.stars == 1)
        #expect(!viewModel.canCheck)

        let attempts = try container.mainContext.fetch(FetchDescriptor<TracingAttempt>())
        #expect(attempts.count == 1)
        #expect(attempts.first?.isCorrect == true)
        #expect(attempts.first?.itemID == "ta-அ")
        #expect(attempts.first?.profile === profile)

        let progress = try container.mainContext.fetch(FetchDescriptor<LessonProgress>())
        #expect(progress.map(\.itemID) == ["ta-அ"])
        #expect(progress.first?.isCompleted == true)

        let badges = try container.mainContext.fetch(FetchDescriptor<EarnedBadge>())
        #expect(badges.map(\.badgeID) == [Badge.firstStar.id])
    }

    @Test("A wrong tracing gives no star but still saves the attempt")
    func wrongTracing() async throws {
        viewModel.strokes = [[CGPoint(x: 0.05, y: 0.05), CGPoint(x: 0.95, y: 0.95)]]
        await viewModel.check(profile: profile)

        #expect(viewModel.status == .wrong)
        #expect(viewModel.wrongCount == 1)
        #expect(profile.stars == 0)

        let attempts = try container.mainContext.fetch(FetchDescriptor<TracingAttempt>())
        #expect(attempts.count == 1)
        #expect(attempts.first?.isCorrect == false)
        #expect(try container.mainContext.fetch(FetchDescriptor<LessonProgress>()).isEmpty)
    }

    @Test("Clear wipes the drawing and goes back to the drawing state")
    func clearResets() async {
        viewModel.strokes = [[CGPoint(x: 0.05, y: 0.05), CGPoint(x: 0.95, y: 0.95)]]
        await viewModel.check(profile: profile)
        viewModel.clear()
        #expect(viewModel.strokes.isEmpty)
        #expect(viewModel.status == .drawing)
    }
}
