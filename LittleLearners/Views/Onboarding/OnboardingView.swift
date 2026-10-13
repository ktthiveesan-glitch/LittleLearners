//
//  OnboardingView.swift
//  LittleLearners
//

import SwiftUI
import SwiftData

/// The screen that creates a child profile. It is shown when the app has no profile yet,
/// and again whenever a child is added from the profile picker. The child (with a parent) types a name,
/// picks an avatar emoji and a language, then taps the button to save a `ChildProfile`.
struct OnboardingView: View {
    /// The SwiftData context used to save the new profile.
    @Environment(\.modelContext) private var modelContext

    /// Holds the name and avatar while the user is choosing.
    @State private var viewModel = OnboardingViewModel()

    /// The app language setting. Changing it saves it straight away, and the whole app,
    /// including this screen, switches language immediately.
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.english.rawValue

    /// Called with the new profile after it is saved. `RootView` uses it to select the child and show Home.
    let onFinished: (ChildProfile) -> Void

    /// Called when Cancel is tapped. Only given when adding another child from the profile picker;
    /// the very first onboarding cannot be cancelled, so there it is `nil` and no Cancel button is shown.
    var onCancel: (() -> Void)?

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.large) {
                Text("Welcome to Little Learners")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                nameSection
                avatarSection
                languageSection
                startButton
                if let onCancel {
                    Button("Cancel", action: onCancel)
                        .font(.title3)
                        .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget)
                }
            }
            .padding(Theme.Spacing.large)
            // Stops the form from stretching too wide on iPad and in landscape.
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.background)
    }

    /// The question and text field for the child's name.
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("What is your name?")
                .font(.title2)
                .bold()
            TextField("Name", text: $viewModel.name)
                .font(.title2)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .padding(.horizontal, Theme.Spacing.medium)
                .frame(minHeight: Theme.minTouchTarget)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
        }
    }

    /// The avatar choices.
    private var avatarSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Pick your picture")
                .font(.title2)
                .bold()
            AvatarPicker(selection: $viewModel.avatar)
        }
    }

    /// A big segmented picker with the three languages, each written in its own script.
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Choose a language")
                .font(.title2)
                .bold()
            BigSegmentedPicker(options: AppLanguage.allCases.map(\.rawValue),
                               title: { code in AppLanguage(rawValue: code)?.displayName ?? code },
                               selection: $languageCode)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Choose a language")
        }
    }

    /// Saves the profile. Disabled (and faded) until a name is typed.
    private var startButton: some View {
        Button {
            if let profile = viewModel.save(in: modelContext) {
                onFinished(profile)
            }
        } label: {
            Text("Let's go!")
                .font(.title2)
                .bold()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget)
                .background(Theme.primary, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        }
        .bouncyPress()
        .disabled(!viewModel.canSave)
        .opacity(viewModel.canSave ? 1 : 0.5)
    }
}

#Preview {
    OnboardingView(onFinished: { _ in })
        .modelContainer(PreviewData.container)
}
