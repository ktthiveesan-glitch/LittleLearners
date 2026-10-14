//
//  ShapesGameViewModelTests.swift
//  LittleLearnersTests
//

import Testing
import SwiftUI
import SwiftData
@testable import LittleLearners

/// Tests for the shapes game logic. The screen positions are made up:
/// every outline is a 100-point square at the top and every shape starts 300 points below its outline.
@MainActor
struct ShapesGameViewModelTests {
    private let container: ModelContainer
    private let profile = ChildProfile(name: "Test", avatar: "🐻")
    private let viewModel = ShapesGameViewModel()

    init() throws {
        container = try TestSupport.makeContainer()
        container.mainContext.insert(profile)
        for (index, shape) in viewModel.targets.enumerated() {
            let x = CGFloat(index) * 120
            viewModel.targetFrames[shape.id] = CGRect(x: x, y: 0, width: 100, height: 100)
            viewModel.pieceFrames[shape.id] = CGRect(x: x, y: 300, width: 100, height: 100)
        }
    }

    @Test("The game starts with six shapes and none placed")
    func startsEmpty() {
        #expect(viewModel.pieces.count == 6)
        #expect(Set(viewModel.pieces.map(\.id)) == Set(viewModel.targets.map(\.id)))
        #expect(!viewModel.isComplete)
        #expect(viewModel.offset(for: viewModel.pieces[0]) == .zero)
    }

    @Test("Dropping a shape on its own outline places it")
    func correctDrop() {
        let circle = viewModel.targets[0]
        viewModel.dragChanged(circle, translation: CGSize(width: 0, height: -300))
        #expect(viewModel.isDragging(circle))
        #expect(viewModel.isOverOwnTarget(circle))

        viewModel.dragEnded(circle, profile: profile)
        #expect(viewModel.isMatched(circle))
        #expect(!viewModel.isDragging(circle))
        // A placed shape is drawn on top of its outline.
        #expect(viewModel.offset(for: circle) == CGSize(width: 0, height: -300))
    }

    @Test("Dropping a shape on another outline sends it back")
    func wrongDrop() {
        let circle = viewModel.targets[0]
        // Move it onto the second outline, 120 points to the right.
        viewModel.dragChanged(circle, translation: CGSize(width: 120, height: -300))
        #expect(!viewModel.isOverOwnTarget(circle))

        viewModel.dragEnded(circle, profile: profile)
        #expect(!viewModel.isMatched(circle))
        #expect(viewModel.offset(for: circle) == .zero)
    }

    @Test("Placing all six shapes finishes the game, saves progress and wins the badge")
    func completingTheGame() throws {
        for shape in viewModel.targets {
            viewModel.place(shape, profile: profile)
        }
        #expect(viewModel.isComplete)

        let progress = try container.mainContext.fetch(FetchDescriptor<LessonProgress>())
        #expect(progress.count == 6)
        #expect(progress.allSatisfy { $0.isCompleted && $0.category == .shapes })

        let badges = try container.mainContext.fetch(FetchDescriptor<EarnedBadge>())
        #expect(badges.map(\.badgeID) == [Badge.shapesChampion.id])
    }

    @Test("Play again clears the placed shapes")
    func playAgain() {
        for shape in viewModel.targets {
            viewModel.place(shape, profile: profile)
        }
        viewModel.playAgain()
        #expect(!viewModel.isComplete)
        #expect(viewModel.pieces.count == 6)
        #expect(!viewModel.isMatched(viewModel.targets[0]))
    }

    @Test("Playing twice does not save the progress twice")
    func progressIsNotDuplicated() throws {
        let circle = viewModel.targets[0]
        viewModel.place(circle, profile: profile)
        viewModel.playAgain()
        viewModel.place(circle, profile: profile)
        #expect(try container.mainContext.fetch(FetchDescriptor<LessonProgress>()).count == 1)
    }
}
