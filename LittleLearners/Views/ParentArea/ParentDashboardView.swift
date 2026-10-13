//
//  ParentDashboardView.swift
//  LittleLearners
//

import SwiftUI
import SwiftData

/// The parent dashboard, shown after the parental gate. It shows the selected child's stars, progress and
/// recent tracing attempts, lets a parent edit or delete children, and has settings for language,
/// sound and resetting progress.
struct ParentDashboardView: View {
    @Environment(\.modelContext) private var modelContext

    /// The child whose progress is shown.
    let profile: ChildProfile

    /// This child's tracing attempts of the last 7 days, for the stars chart (the filter is set in `init`).
    @Query private var chartAttempts: [TracingAttempt]

    /// This child's ten newest tracing attempts, for the list (the filter is set in `init`).
    @Query private var recentAttempts: [TracingAttempt]

    /// The app language setting, saved as its code ("en", "si" or "ta").
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.english.rawValue

    /// The app language as a `Locale`, set by `RootView`.
    @Environment(\.locale) private var locale

    /// The user's text size setting.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The sound setting. When off, the app does not read anything aloud.
    @AppStorage(SpeechService.soundOnKey) private var isSoundOn = true

    /// Turns the records into chart data.
    @State private var viewModel = ParentDashboardViewModel()

    /// True while the "are you sure?" alert for reset is showing.
    @State private var showsResetAlert = false

    /// The child being edited. Setting it shows the edit sheet; `nil` hides it.
    @State private var editingProfile: ChildProfile?

    /// Sets up the two queries so they only load this child's attempts: the last 7 days for the chart
    /// and the ten newest for the list. Without the filters the dashboard would load every attempt of every child.
    init(profile: ChildProfile) {
        self.profile = profile
        let profileID = profile.profileID
        let chartStart = ParentDashboardViewModel.chartStartDate()
        _chartAttempts = Query(ParentDashboardViewModel.chartAttemptsDescriptor(for: profileID, from: chartStart))
        _recentAttempts = Query(ParentDashboardViewModel.recentAttemptsDescriptor(for: profileID))
    }

    var body: some View {
        List {
            // Whose progress this is.
            HStack(spacing: Theme.Spacing.medium) {
                Text(profile.avatar)
                    .font(.largeTitle)
                    .accessibilityHidden(true)
                Text(profile.name)
                    .font(.title)
                    .bold()
            }
            Section("Stars in the last 7 days") {
                StarsPerDayChart(days: viewModel.dailyStars(from: chartAttempts))
                    .padding(.vertical, Theme.Spacing.small)
            }
            progressSection
            recentAttemptsSection
            ChildrenSection(onEdit: { editingProfile = $0 })
            settingsSection
        }
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        // A navigation title is not redrawn when only the language changes, and this is the one screen
        // where the language can change while it is open. So the title is looked up as a `String`:
        // a new language gives a new string, and that does update the title.
        .navigationTitle(LocalizedStringResource("Parent area").text(in: locale))
        .sheet(item: $editingProfile) { child in
            ProfileEditView(profile: child)
        }
        .alert("Reset all progress?", isPresented: $showsResetAlert) {
            Button("Reset", role: .destructive) {
                viewModel.resetProgress(of: profile, in: modelContext)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Stars, badges and tracing history will be deleted. This cannot be undone.")
        }
    }

    /// The progress chart, with the exact numbers per category written underneath.
    private var progressSection: some View {
        let categories = viewModel.categoryProgress(from: profile.progress)
        return Section("Progress") {
            CategoryProgressChart(progress: categories)
                .padding(.vertical, Theme.Spacing.small)
            ForEach(categories) { item in
                LabeledContent {
                    Text("\(item.completed) of \(item.total)")
                } label: {
                    Text(item.category.title)
                }
            }
        }
    }

    /// The newest tracing attempts, or a note when there are none.
    private var recentAttemptsSection: some View {
        Section("Recent tracing") {
            if recentAttempts.isEmpty {
                Text("No tracing yet")
                    .foregroundStyle(.secondary)
            }
            ForEach(recentAttempts) { attempt in
                attemptRow(attempt)
            }
        }
    }

    /// One attempt: the character, when it was traced, the score, and a tick or a cross.
    /// With very large text the score moves under the date, so the row has room for the words.
    private func attemptRow(_ attempt: TracingAttempt) -> some View {
        let score = Text(attempt.score, format: .percent.precision(.fractionLength(0)))
            .foregroundStyle(.secondary)
        return HStack(spacing: Theme.Spacing.medium) {
            Text(attempt.character)
                .font(.title)
                .bold()
                .frame(minWidth: 44)
            VStack(alignment: .leading) {
                Text(attempt.isCorrect ? "Correct" : "Not yet")
                    .font(.headline)
                Text(attempt.date, format: .dateTime.day().month().hour().minute())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if dynamicTypeSize.isAccessibilitySize {
                    score
                }
            }
            Spacer()
            if !dynamicTypeSize.isAccessibilitySize {
                score
            }
            Image(systemName: attempt.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(attempt.isCorrect ? Theme.success : Theme.accent)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }

    /// Language, sound and reset. Each row is at least 60 points tall, like the rest of the app.
    private var settingsSection: some View {
        Section("Settings") {
            Picker("Language", selection: $languageCode) {
                ForEach(AppLanguage.allCases) { language in
                    Text(verbatim: language.displayName).tag(language.rawValue)
                }
            }
            .frame(minHeight: Theme.minTouchTarget)
            Toggle("Sound", isOn: $isSoundOn)
                .frame(minHeight: Theme.minTouchTarget)
            Button("Reset progress", role: .destructive) {
                showsResetAlert = true
            }
            .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        ParentDashboardView(profile: PreviewData.profile)
    }
    .modelContainer(PreviewData.container)
}
