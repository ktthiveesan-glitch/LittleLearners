//
//  Badge.swift
//  LittleLearners
//

import Foundation

/// Every badge (sticker) a child can win. This is the fixed list; which ones a child
/// has actually won is saved in SwiftData as `EarnedBadge` records, using the raw value as the id.
enum Badge: String, CaseIterable, Identifiable {
    case firstStar = "first-star"
    case tenStars = "ten-stars"
    case fiftyStars = "fifty-stars"
    case englishLetters = "english-letters"
    case sinhalaLetters = "sinhala-letters"
    case tamilLetters = "tamil-letters"
    case allNumbers = "all-numbers"
    case shapesChampion = "shapes-champion"

    var id: String { rawValue }

    /// The picture on the sticker.
    var emoji: String {
        switch self {
        case .firstStar: "⭐"
        case .tenStars: "🌟"
        case .fiftyStars: "🏆"
        case .englishLetters: "🔤"
        case .sinhalaLetters: "අ"
        case .tamilLetters: "அ"
        case .allNumbers: "🔢"
        case .shapesChampion: "🔺"
        }
    }

    /// The badge's name, translated into the app language.
    var title: LocalizedStringResource {
        switch self {
        case .firstStar: "First Star"
        case .tenStars: "Ten Stars"
        case .fiftyStars: "Fifty Stars"
        case .englishLetters: "English Letters"
        case .sinhalaLetters: "Sinhala Letters"
        case .tamilLetters: "Tamil Letters"
        case .allNumbers: "All Numbers"
        case .shapesChampion: "Shape Champion"
        }
    }

    /// One short sentence that tells the child how to win the badge.
    var howToEarn: LocalizedStringResource {
        switch self {
        case .firstStar: "Earn your first star"
        case .tenStars: "Earn 10 stars"
        case .fiftyStars: "Earn 50 stars"
        case .englishLetters: "Trace every English letter"
        case .sinhalaLetters: "Trace every Sinhala letter"
        case .tamilLetters: "Trace every Tamil letter"
        case .allNumbers: "Trace every number"
        case .shapesChampion: "Finish the shapes game"
        }
    }
}
