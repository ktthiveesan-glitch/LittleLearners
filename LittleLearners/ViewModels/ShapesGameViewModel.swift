//
//  ShapesGameViewModel.swift
//  LittleLearners
//

import SwiftUI
import SwiftData

/// The logic of the shapes game: which shapes are placed, where a dragged shape is,
/// and whether a drop landed on the right outline.
@Observable
final class ShapesGameViewModel {
    /// The outlines at the top, in a fixed order.
    let targets = LearningContent.shapes

    /// The draggable shapes at the bottom, in a mixed-up order.
    private(set) var pieces = LearningContent.shapes.shuffled()

    /// The ids of the shapes already placed on their outline.
    private(set) var matchedIDs: Set<String> = []

    /// The id of the shape being dragged right now, if any.
    private(set) var draggingID: String?

    /// How far the dragged shape has moved from its starting place.
    private(set) var dragTranslation: CGSize = .zero

    /// Where each outline is on screen, reported by the view. Key = shape id.
    var targetFrames: [String: CGRect] = [:]

    /// Where each shape's starting place is on screen, reported by the view. Key = shape id.
    var pieceFrames: [String: CGRect] = [:]

    /// True when every shape is on its outline.
    var isComplete: Bool {
        matchedIDs.count == targets.count
    }

    func isMatched(_ piece: LearningItem) -> Bool {
        matchedIDs.contains(piece.id)
    }

    func isDragging(_ piece: LearningItem) -> Bool {
        draggingID == piece.id
    }

    /// How far to draw a shape from its starting place:
    /// - placed: the distance to its outline, so it sits on top of it (this still works after rotation);
    /// - being dragged: it follows the finger;
    /// - otherwise: zero, so it rests in the tray.
    func offset(for piece: LearningItem) -> CGSize {
        if isMatched(piece), let target = targetFrames[piece.id], let home = pieceFrames[piece.id] {
            return CGSize(width: target.midX - home.midX, height: target.midY - home.midY)
        }
        if isDragging(piece) {
            return dragTranslation
        }
        return .zero
    }

    /// Called while the finger moves.
    func dragChanged(_ piece: LearningItem, translation: CGSize) {
        draggingID = piece.id
        dragTranslation = translation
    }

    /// True if the shape, dropped where it is now, lies on its own outline.
    func isOverOwnTarget(_ piece: LearningItem) -> Bool {
        guard let target = targetFrames[piece.id], let home = pieceFrames[piece.id] else { return false }
        let dropPoint = CGPoint(x: home.midX + dragTranslation.width, y: home.midY + dragTranslation.height)
        return target.contains(dropPoint)
    }

    /// Called when the finger lifts. A correct drop places the shape; a wrong one sends it home.
    /// The view calls this inside `withAnimation`, so both movements are animated.
    func dragEnded(_ piece: LearningItem, profile: ChildProfile) {
        if isOverOwnTarget(piece) {
            place(piece, profile: profile)
        }
        draggingID = nil
        dragTranslation = .zero
    }

    /// Puts a shape on its outline, saves the progress for the given child,
    /// and checks for a new badge when the game is finished.
    /// Also used directly by VoiceOver users, who cannot drag.
    func place(_ piece: LearningItem, profile: ChildProfile) {
        matchedIDs.insert(piece.id)
        ProgressService.markCompleted(piece, for: profile)
        if isComplete {
            BadgeService.awardNewBadges(for: profile)
            // Save now, so the finished game and the badge are on disk even if the app is closed straight away.
            try? profile.modelContext?.save()
        }
    }

    /// Starts a new round with the shapes mixed up again.
    func playAgain() {
        matchedIDs = []
        pieces = targets.shuffled()
    }
}
