//
//  RootView.swift
//  LittleLearners
//

import SwiftUI
import SwiftData

/// The first view of the app. It decides what to show:
/// - no child profile yet: onboarding;
/// - a child is selected: Home inside a `NavigationStack`;
/// - otherwise: the profile picker ("Who is learning today?").
struct RootView: View {
    /// All saved child profiles, oldest first. SwiftUI redraws this view when one is added or deleted.
    @Query(sort: \ChildProfile.createdAt) private var profiles: [ChildProfile]

    /// The language chosen in the app, saved as its code ("en", "si" or "ta").
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.english.rawValue

    /// The id of the selected child, remembered between launches. Empty when no child is selected.
    @AppStorage(ChildProfile.activeProfileKey) private var activeProfileID = ""

    /// True while the profile picker should be shown. It starts as true, so the picker is the
    /// first screen every time the app opens.
    @State private var showsProfilePicker = true

    /// Owns the navigation path and shares it with every screen through the environment.
    @State private var router = Router()

    /// Links the avatar on the profile picker to the avatar on Home for `matchedGeometryEffect`.
    @Namespace private var avatarNamespace

    /// The selected child, found by the remembered id. `nil` if that child no longer exists.
    private var activeProfile: ChildProfile? {
        profiles.first { $0.profileID.uuidString == activeProfileID }
    }

    var body: some View {
        Group {
            if profiles.isEmpty {
                OnboardingView(onFinished: select)
            } else if let profile = activeProfile, !showsProfilePicker {
                NavigationStack(path: $router.path) {
                    HomeView(profile: profile, avatarNamespace: avatarNamespace, onSwitchProfile: showProfilePicker)
                        .navigationDestination(for: Route.self) { route in
                            destination(for: route)
                        }
                }
                .environment(router)
                // Every screen in the stack can read the selected child from the environment,
                // so progress, stars, attempts and badges always go to this child.
                .environment(profile)
            } else {
                ProfilePickerView(profiles: profiles, selectedProfileID: activeProfileID,
                                  avatarNamespace: avatarNamespace, onSelect: select)
            }
        }
        // Every screen reads its language from here. Because `languageCode` is `@AppStorage`,
        // changing it anywhere in the app redraws all visible text in the new language at once.
        .environment(\.locale, Locale(identifier: languageCode))
    }

    /// Makes a child the selected one and shows Home. The change is animated,
    /// which lets the avatar move from the picker card to its place on Home.
    private func select(_ profile: ChildProfile) {
        router.popToRoot()
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            activeProfileID = profile.profileID.uuidString
            showsProfilePicker = false
        }
    }

    /// Goes back to the profile picker (the avatar on Home was tapped).
    private func showProfilePicker() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            showsProfilePicker = true
        }
    }

    /// Returns the screen for a route.
    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .characterList(let category):
            CharacterGridView(category: category)
        case .lesson(let item):
            LessonDetailView(item: item)
        case .tracing(let item):
            TracingView(item: item)
        case .shapesGame:
            ShapesGameView()
        case .rewards:
            RewardsView()
        case .parentArea:
            ParentAreaView()
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewData.container)
}
