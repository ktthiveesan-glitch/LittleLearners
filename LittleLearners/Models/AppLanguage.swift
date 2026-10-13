//
//  AppLanguage.swift
//  LittleLearners
//

import Foundation

/// The three languages the app can be used in.
/// The raw value is the standard language code ("en", "si", "ta").
/// The choice is a small setting, so it is saved with `@AppStorage` / `UserDefaults`, not SwiftData.
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case sinhala = "si"
    case tamil = "ta"

    /// The key the chosen language is saved under in `UserDefaults`.
    static let storageKey = "appLanguage"

    /// The language chosen during onboarding. English if nothing is saved yet.
    static var current: AppLanguage {
        let savedCode = UserDefaults.standard.string(forKey: storageKey) ?? ""
        return AppLanguage(rawValue: savedCode) ?? .english
    }

    var id: String { rawValue }

    /// The writing system that goes with this language.
    var script: Script {
        switch self {
        case .english: .english
        case .sinhala: .sinhala
        case .tamil: .tamil
        }
    }

    /// The `Locale` for this language. `RootView` puts it in the SwiftUI environment,
    /// and SwiftUI then shows every `Text` in this language.
    var locale: Locale { Locale(identifier: rawValue) }

    /// Returns a text in this language as a plain `String`.
    /// Needed where SwiftUI cannot translate for us, for example words that are spoken aloud.
    func text(_ resource: LocalizedStringResource) -> String {
        resource.text(in: locale)
    }

    /// The language's own name. It is never translated, so a Tamil speaker can always find "தமிழ்".
    var displayName: String { script.displayName }
}

extension LocalizedStringResource {
    /// Looks this text up in the translations for the given locale and returns it as a `String`.
    /// A `LocalizedStringResource` remembers which locale to use, so we set it on a copy first.
    func text(in locale: Locale) -> String {
        var copy = self
        copy.locale = locale
        return String(localized: copy)
    }
}
