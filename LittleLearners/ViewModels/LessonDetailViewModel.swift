//
//  LessonDetailViewModel.swift
//  LittleLearners
//

import Foundation

/// Keeps track of which character the lesson screen is showing and lets the child
/// move to the next or previous one and hear it read aloud.
@Observable
final class LessonDetailViewModel {
    /// All the items in the same list as the starting item (for example all English letters).
    let items: [LearningItem]

    /// The position of the item on screen inside `items`.
    private(set) var index: Int

    /// True if the last move was to the next item. The view uses it to pick the slide direction.
    private(set) var isMovingForward = true

    /// Reads the character and word aloud.
    private let speechService = SpeechService()

    init(item: LearningItem) {
        items = LearningContent.siblings(of: item)
        index = items.firstIndex { $0.id == item.id } ?? 0
    }

    /// The item currently on screen.
    var item: LearningItem { items[index] }

    var hasPrevious: Bool { index > 0 }
    var hasNext: Bool { index < items.count - 1 }

    /// Moves to the next item, if there is one.
    func goToNext() {
        guard hasNext else { return }
        isMovingForward = true
        index += 1
    }

    /// Moves to the previous item, if there is one.
    func goToPrevious() {
        guard hasPrevious else { return }
        isMovingForward = false
        index -= 1
    }

    /// Letters are read in their own language. Number names are in the app language.
    private var speechLanguageCode: String {
        item.script?.speechLanguageCode ?? AppLanguage.current.script.speechLanguageCode
    }

    /// False when sound is switched off or the device has no voice for this item's language.
    /// The view then hides the speak button.
    var canSpeak: Bool {
        speechService.canSpeak(in: speechLanguageCode)
    }

    /// Reads the current item aloud: "A. Apple" for a letter, or just "Three" for a number.
    func speak() {
        let text = item.category == .letters ? "\(item.character). \(item.word)" : item.word
        speechService.speak(text, languageCode: speechLanguageCode)
    }
}
