//
//  ProfileEditViewModel.swift
//  LittleLearners
//

import Foundation
import SwiftData

/// Holds the changes a parent makes to one child's name and avatar, and can delete the child.
/// The profile itself is only changed when Save is tapped, so Cancel throws the changes away.
@Observable
final class ProfileEditViewModel {
    /// The child being edited.
    let profile: ChildProfile

    /// The name in the text field. Starts as the child's current name.
    var name: String

    /// The chosen avatar. Starts as the child's current avatar.
    var avatar: String

    init(profile: ChildProfile) {
        self.profile = profile
        name = profile.name
        avatar = profile.avatar
    }

    /// The name without spaces at the start or end.
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Save is only possible with a name.
    var canSave: Bool {
        !trimmedName.isEmpty
    }

    /// Writes the new name and avatar to the profile.
    func save() {
        guard canSave else { return }
        profile.name = trimmedName
        profile.avatar = avatar
        // Save now, so the change is on disk even if the app is closed straight away.
        try? profile.modelContext?.save()
    }

    /// Deletes the child. Because of the cascade delete rule on `ChildProfile`,
    /// SwiftData also deletes that child's progress, tracing attempts and badges.
    func delete(in context: ModelContext) {
        // If this is the selected child, forget the selection first.
        // `RootView` then leaves Home and shows the profile picker (or onboarding if no child is left).
        let defaults = UserDefaults.standard
        if defaults.string(forKey: ChildProfile.activeProfileKey) == profile.profileID.uuidString {
            defaults.removeObject(forKey: ChildProfile.activeProfileKey)
        }
        context.delete(profile)
        // Save now, so the child does not come back if the app is closed straight away.
        try? context.save()
    }
}
