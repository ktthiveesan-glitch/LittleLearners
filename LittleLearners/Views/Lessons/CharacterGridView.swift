//
//  CharacterGridView.swift
//  LittleLearners
//

import SwiftUI

/// A grid of all the letters or numbers in a category. Tapping one opens its lesson.
/// For letters, a segmented picker at the top switches between English, Sinhala and Tamil.
struct CharacterGridView: View {
    /// Decides which items to show.
    @State private var viewModel: CharacterGridViewModel

    /// Smallest width of one cell. The grid fits as many columns as the screen allows,
    /// so it adapts to iPhone, iPad, portrait and landscape by itself.
    @ScaledMetric private var cellMinWidth: CGFloat = 90

    init(category: LearningCategory) {
        _viewModel = State(initialValue: CharacterGridViewModel(category: category))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.large) {
                if viewModel.showsScriptPicker {
                    scriptPicker
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: cellMinWidth), spacing: Theme.Spacing.medium)],
                          spacing: Theme.Spacing.medium) {
                    ForEach(viewModel.items) { item in
                        NavigationLink(value: Route.lesson(item)) {
                            cell(for: item)
                        }
                        .bouncyPress()
                    }
                }
            }
            .padding(Theme.Spacing.large)
        }
        .background(Theme.background)
        .navigationTitle(Text(viewModel.category.title))
    }

    /// The English / Sinhala / Tamil picker. Each name is written in its own script.
    private var scriptPicker: some View {
        BigSegmentedPicker(options: Script.allCases, title: \.displayName, selection: $viewModel.script)
            // VoiceOver reads "Script" before the three choices.
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Script")
    }

    /// One square cell showing the character. VoiceOver reads the character and its word, e.g. "A, Apple".
    private func cell(for item: LearningItem) -> some View {
        KidsCard {
            Text(item.character)
                .font(.largeTitle)
                .bold()
                .foregroundStyle(Theme.color(for: item.category))
                .frame(minHeight: Theme.minTouchTarget)
        }
        .accessibilityLabel(Text(verbatim: "\(item.character), \(item.word)"))
    }
}

#Preview {
    NavigationStack {
        CharacterGridView(category: .letters)
    }
}
