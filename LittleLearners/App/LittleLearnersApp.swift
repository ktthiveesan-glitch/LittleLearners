//
//  LittleLearnersApp.swift
//  LittleLearners
//
//  Created by Gabilan Sivanesan on 2026-10-12.
//

import SwiftUI
import SwiftData

/// The starting point of the app. It shows `RootView` and sets up the SwiftData
/// database for the four model types, so every screen can read and save data.
@main
struct LittleLearnersApp: App {
    /// True when the app was started by the UI tests (they pass the launch argument "-uiTesting").
    /// The app then starts empty every time, so each test begins at onboarding and
    /// the tests never touch a real child's data.
    private let isUITesting = ProcessInfo.processInfo.arguments.contains("-uiTesting")

    init() {
        if isUITesting {
            // Forget the saved language, sound setting and selected child.
            UserDefaults.standard.removeObject(forKey: ChildProfile.activeProfileKey)
            UserDefaults.standard.removeObject(forKey: AppLanguage.storageKey)
            UserDefaults.standard.removeObject(forKey: SpeechService.soundOnKey)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        // During UI tests the database is kept in memory only, so nothing is saved to disk.
        .modelContainer(for: [
            ChildProfile.self,
            LessonProgress.self,
            TracingAttempt.self,
            EarnedBadge.self,
        ], inMemory: isUITesting)
    }
}
