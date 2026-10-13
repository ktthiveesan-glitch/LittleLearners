//
//  OnboardingViewModel.swift
//  LittleLearners
//

import Foundation
import SwiftData

/// Holds the name and avatar chosen on the onboarding screen, and saves them at the end.
@Observable
final class OnboardingViewModel {
    /// The name typed into the text field.
    var name = ""

    /// The chosen avatar emoji. Starts on the first one so there is always a choice.
    var avatar = AvatarPicker.avatars[0]

    /// The name without spaces at the start or end.
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// True when a name has been typed, so the profile can be saved.
    var canSave: Bool {
        !trimmedName.isEmpty
    }

    /// Saves a new child profile in SwiftData and returns it, or returns `nil` if no name was typed.
    /// (The language is not saved here: the picker saves it the moment it is changed.)
    @discardableResult
    func save(in context: ModelContext) -> ChildProfile? {
        guard canSave else { return nil }
        let profile = ChildProfile(name: trimmedName, avatar: avatar)
        context.insert(profile)
        // SwiftData normally saves a little later by itself. Saving now makes sure the new child
        // is on disk even if the app is closed straight after onboarding.
        try? context.save()
        return profile
    }
}
