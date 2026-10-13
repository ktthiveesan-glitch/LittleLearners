//
//  CharacterGridViewModel.swift
//  LittleLearners
//

import Foundation

/// Decides which characters the grid screen shows.
@Observable
final class CharacterGridViewModel {
    /// The category being shown (letters or numbers).
    let category: LearningCategory

    /// The script picked in the segmented picker. Only used for letters.
    /// It starts on the script of the app language chosen in onboarding.
    var script: Script = AppLanguage.current.script

    init(category: LearningCategory) {
        self.category = category
    }

    /// Only letters come in three scripts, so only letters show the picker.
    var showsScriptPicker: Bool {
        category == .letters
    }

    /// The items to show in the grid.
    var items: [LearningItem] {
        switch category {
        case .letters: LearningContent.letters(for: script)
        case .numbers: LearningContent.numbers
        case .shapes: LearningContent.shapes
        }
    }
}
