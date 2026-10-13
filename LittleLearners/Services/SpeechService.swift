//
//  SpeechService.swift
//  LittleLearners
//

import AVFoundation

/// Reads text aloud using the voices built into iOS (`AVSpeechSynthesizer`).
/// It works offline and sends nothing over the network.
final class SpeechService {
    /// The key the sound on/off setting is saved under in `UserDefaults`. Parents change it in the parent area.
    static let soundOnKey = "soundOn"

    /// The system object that does the talking. One is kept so a new word can stop the old one.
    private let synthesizer = AVSpeechSynthesizer()

    /// Voices already looked up, by language code. Asking iOS for a voice is slow compared with a
    /// dictionary lookup, and screens ask every time they redraw, so each answer is remembered.
    /// `nil` inside the dictionary means "we asked, and there is no voice for this language".
    private var voiceCache: [String: AVSpeechSynthesisVoice?] = [:]

    /// Returns the voice for a language, asking iOS only the first time.
    private func voice(for languageCode: String) -> AVSpeechSynthesisVoice? {
        if let cached = voiceCache[languageCode] {
            return cached
        }
        let voice = AVSpeechSynthesisVoice(language: languageCode)
        voiceCache[languageCode] = voice
        return voice
    }

    /// True if this device has a voice for the language, e.g. "en-US" or "ta-IN".
    /// Many devices have no Sinhala voice, so screens use this to hide the speak button.
    func hasVoice(for languageCode: String) -> Bool {
        voice(for: languageCode) != nil
    }

    /// True unless a parent has switched sound off. Sound is on when nothing is saved yet.
    var isSoundOn: Bool {
        UserDefaults.standard.object(forKey: Self.soundOnKey) as? Bool ?? true
    }

    /// True if speaking in this language would actually make a sound:
    /// sound is switched on and the device has a voice for the language.
    func canSpeak(in languageCode: String) -> Bool {
        isSoundOn && hasVoice(for: languageCode)
    }

    /// Reads `text` aloud in the given language.
    /// If sound is off, or the device has no voice for that language, it does nothing (fails silently),
    /// and the child still sees the text on screen.
    func speak(_ text: String, languageCode: String) {
        guard isSoundOn, let voice = voice(for: languageCode) else { return }

        // Stop anything still being read, so quick taps do not queue up.
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        // A little slower than normal so young children can follow.
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        synthesizer.speak(utterance)
    }
}
