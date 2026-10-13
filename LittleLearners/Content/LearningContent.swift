//
//  LearningContent.swift
//  LittleLearners
//

import Foundation

/// All the fixed learning content in the app: letters, numbers and shapes.
/// Nothing here is downloaded; it is all built into the app.
enum LearningContent {

    // MARK: - Letters
    // Example words for letters are NOT translated on purpose:
    // "Apple" teaches the English letter A, so it must stay in English in every app language.

    /// English letters A–Z with an example word each.
    static let englishLetters: [LearningItem] = [
        letter("A", "Apple", "🍎", .english),
        letter("B", "Ball", "⚽", .english),
        letter("C", "Cat", "🐱", .english),
        letter("D", "Dog", "🐶", .english),
        letter("E", "Elephant", "🐘", .english),
        letter("F", "Fish", "🐟", .english),
        letter("G", "Grapes", "🍇", .english),
        letter("H", "Hat", "🎩", .english),
        letter("I", "Ice cream", "🍦", .english),
        letter("J", "Juice", "🧃", .english),
        letter("K", "Kite", "🪁", .english),
        letter("L", "Lion", "🦁", .english),
        letter("M", "Moon", "🌙", .english),
        letter("N", "Nest", "🪺", .english),
        letter("O", "Orange", "🍊", .english),
        letter("P", "Parrot", "🦜", .english),
        letter("Q", "Queen", "👑", .english),
        letter("R", "Rainbow", "🌈", .english),
        letter("S", "Sun", "☀️", .english),
        letter("T", "Tree", "🌳", .english),
        letter("U", "Umbrella", "☂️", .english),
        letter("V", "Van", "🚐", .english),
        letter("W", "Watch", "⌚", .english),
        letter("X", "X-ray", "🩻", .english),
        letter("Y", "Yo-yo", "🪀", .english),
        letter("Z", "Zebra", "🦓", .english),
    ]

    /// Sinhala vowels අ to ඖ. These are the 14 vowels usually taught first;
    /// the four rare vowels (ඍ ඎ ඏ ඐ) are left out because they have no simple words for young children.
    static let sinhalaVowels: [LearningItem] = [
        letter("අ", "අම්මා", "👩", .sinhala),      // mother
        letter("ආ", "ආච්චි", "👵", .sinhala),      // grandmother
        letter("ඇ", "ඇස", "👁️", .sinhala),        // eye
        letter("ඈ", "ඈත", "🏔️", .sinhala),        // far away
        letter("ඉ", "ඉර", "☀️", .sinhala),         // sun
        letter("ඊ", "ඊතලය", "🏹", .sinhala),       // arrow
        letter("උ", "උකුස්සා", "🦅", .sinhala),     // hawk
        letter("ඌ", "ඌරා", "🐷", .sinhala),        // pig
        letter("එ", "එළුවා", "🐐", .sinhala),      // goat
        letter("ඒ", "ඒදණ්ඩ", "🌉", .sinhala),      // footbridge
        letter("ඓ", "ඓතිහාසික", "🏛️", .sinhala),  // historical
        letter("ඔ", "ඔටුවා", "🐫", .sinhala),      // camel
        letter("ඕ", "ඕලු", "🪷", .sinhala),        // water lily
        letter("ඖ", "ඖෂධ", "💊", .sinhala),        // medicine
    ]

    /// Tamil vowels அ to ஔ (the 12 uyir letters).
    static let tamilVowels: [LearningItem] = [
        letter("அ", "அம்மா", "👩", .tamil),     // mother
        letter("ஆ", "ஆடு", "🐐", .tamil),       // goat
        letter("இ", "இலை", "🍃", .tamil),       // leaf
        letter("ஈ", "ஈ", "🪰", .tamil),         // fly
        letter("உ", "உடை", "👗", .tamil),       // dress
        letter("ஊ", "ஊசி", "🪡", .tamil),       // needle
        letter("எ", "எலி", "🐭", .tamil),       // rat
        letter("ஏ", "ஏணி", "🪜", .tamil),       // ladder
        letter("ஐ", "ஐந்து", "🖐️", .tamil),     // five
        letter("ஒ", "ஒட்டகம்", "🐫", .tamil),   // camel
        letter("ஓ", "ஓடம்", "⛵", .tamil),      // boat
        letter("ஔ", "ஔவை", "👵", .tamil),      // Avvai, a wise old poet
    ]

    /// Returns the letters for one script.
    static func letters(for script: Script) -> [LearningItem] {
        switch script {
        case .english: englishLetters
        case .sinhala: sinhalaVowels
        case .tamil: tamilVowels
        }
    }

    // MARK: - Numbers and shapes
    // These names ARE translated ("One" becomes "එක" or "ஒன்று"), so the lists are
    // built each time they are read. That way they always use the language chosen in the app.

    /// Numbers 1–10. The emoji is something the child can count.
    static var numbers: [LearningItem] {
        let language = AppLanguage.current
        return [
            number(1, language.text("One"), "🍎"),
            number(2, language.text("Two"), "🐶"),
            number(3, language.text("Three"), "🚗"),
            number(4, language.text("Four"), "🌸"),
            number(5, language.text("Five"), "🐟"),
            number(6, language.text("Six"), "🎈"),
            number(7, language.text("Seven"), "🍌"),
            number(8, language.text("Eight"), "🦋"),
            number(9, language.text("Nine"), "⭐"),
            number(10, language.text("Ten"), "🧁"),
        ]
    }

    /// Six basic shapes. The emoji is an everyday object with that shape.
    static var shapes: [LearningItem] {
        let language = AppLanguage.current
        return [
            shape("circle", "●", language.text("Circle"), "🍪"),
            shape("square", "■", language.text("Square"), "🖼️"),
            shape("triangle", "▲", language.text("Triangle"), "🍕"),
            shape("rectangle", "▬", language.text("Rectangle"), "🚪"),
            shape("star", "★", language.text("Star"), "⭐"),
            shape("heart", "♥", language.text("Heart"), "❤️"),
        ]
    }

    /// Returns the list an item belongs to (for example all English letters for "A").
    /// The lesson screen uses this to move to the next and previous item.
    static func siblings(of item: LearningItem) -> [LearningItem] {
        switch item.category {
        case .letters: letters(for: item.script ?? .english)
        case .numbers: numbers
        case .shapes: shapes
        }
    }

    // MARK: - Small helpers that keep the lists above short

    /// Builds a letter item. The id is the script code plus the letter, e.g. "en-A".
    private static func letter(_ character: String, _ word: String, _ emoji: String, _ script: Script) -> LearningItem {
        let prefix = switch script {
        case .english: "en"
        case .sinhala: "si"
        case .tamil: "ta"
        }
        return LearningItem(id: "\(prefix)-\(character)", character: character, word: word,
                            emoji: emoji, category: .letters, script: script)
    }

    /// Builds a number item, e.g. id "num-3".
    private static func number(_ value: Int, _ word: String, _ emoji: String) -> LearningItem {
        LearningItem(id: "num-\(value)", character: "\(value)", word: word,
                     emoji: emoji, category: .numbers, script: nil)
    }

    /// Builds a shape item, e.g. id "shape-circle".
    private static func shape(_ name: String, _ symbol: String, _ word: String, _ emoji: String) -> LearningItem {
        LearningItem(id: "shape-\(name)", character: symbol, word: word,
                     emoji: emoji, category: .shapes, script: nil)
    }
}
