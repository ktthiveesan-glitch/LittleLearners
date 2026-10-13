//
//  LearningItem.swift
//  LittleLearners
//

import Foundation

/// The three things a child can learn in the app.
enum LearningCategory: String, CaseIterable, Hashable {
    case letters
    case numbers
    case shapes

    /// The name shown on screen, translated into the app language.
    var title: LocalizedStringResource {
        switch self {
        case .letters: "Letters"
        case .numbers: "Numbers"
        case .shapes: "Shapes"
        }
    }

    /// An emoji that stands for the category on the Home screen.
    var emoji: String {
        switch self {
        case .letters: "🔤"
        case .numbers: "🔢"
        case .shapes: "🔺"
        }
    }
}

/// The three writing systems (scripts) the app teaches letters in.
enum Script: String, CaseIterable, Hashable, Identifiable {
    case english
    case sinhala
    case tamil

    var id: String { rawValue }

    /// The script's name written in that script. It is never translated.
    var displayName: String {
        switch self {
        case .english: "English"
        case .sinhala: "සිංහල"
        case .tamil: "தமிழ்"
        }
    }

    /// The voice language used to read this script aloud.
    /// iOS may not have a voice for every language; `SpeechService` handles that.
    var speechLanguageCode: String {
        switch self {
        case .english: "en-US"
        case .sinhala: "si-LK"
        case .tamil: "ta-IN"
        }
    }
}

/// One thing to learn: a letter, a number or a shape.
/// This is plain fixed data (not saved in SwiftData); see `LearningContent` for the full lists.
struct LearningItem: Identifiable, Hashable {
    /// A unique fixed name, e.g. "en-A", "si-අ", "num-3" or "shape-circle".
    /// Progress and tracing attempts are saved against this id.
    let id: String

    /// The big character shown on screen, e.g. "A", "අ", "3" or "●".
    let character: String

    /// An example word (for letters) or the name (for numbers and shapes), e.g. "Apple" or "Three".
    let word: String

    /// A picture for the word, e.g. "🍎".
    let emoji: String

    /// Which category the item belongs to.
    let category: LearningCategory

    /// The script of a letter. `nil` for numbers and shapes.
    let script: Script?
}
