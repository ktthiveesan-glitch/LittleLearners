//
//  RewardsViewModel.swift
//  LittleLearners
//

import Foundation

/// Keeps track of which badge is enlarged on the Rewards screen and reads badge names aloud.
@Observable
final class RewardsViewModel {
    /// The badge shown big in the middle of the screen, or `nil` when none is enlarged.
    var selectedBadge: Badge?

    /// Reads badge names aloud.
    private let speechService = SpeechService()

    /// Says the badge's name in the app language. Does nothing if the device has no voice for it.
    func speakName(of badge: Badge) {
        let language = AppLanguage.current
        speechService.speak(language.text(badge.title), languageCode: language.script.speechLanguageCode)
    }
}
