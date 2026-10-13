//
//  LessonDetailView.swift
//  LittleLearners
//

import SwiftUI

/// The lesson for one letter or number: a big character, an example word with an emoji,
/// a speak button and a "Trace it" button. Swipe left or right (or tap the arrows) to change character.
struct LessonDetailView: View {
    /// Knows the current item and how to move to the next or previous one.
    @State private var viewModel: LessonDetailViewModel

    /// `.compact` when the screen is short, i.e. an iPhone in landscape.
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    /// Size of the big character. Grows with the user's text size.
    @ScaledMetric private var characterSize: CGFloat = 150

    init(item: LearningItem) {
        _viewModel = State(initialValue: LessonDetailViewModel(item: item))
    }

    var body: some View {
        // Side by side when the screen is short (landscape iPhone), stacked otherwise.
        let layout = verticalSizeClass == .compact
            ? AnyLayout(HStackLayout(spacing: Theme.Spacing.large))
            : AnyLayout(VStackLayout(spacing: Theme.Spacing.large))

        layout {
            characterCard
            VStack(spacing: Theme.Spacing.large) {
                wordRow
                controls
                traceButton
            }
        }
        .padding(Theme.Spacing.large)
        .frame(maxWidth: 800, maxHeight: .infinity)
        .frame(maxWidth: .infinity)
        .background(Theme.background)
        // Makes the empty areas of the screen react to the swipe too.
        .contentShape(Rectangle())
        .gesture(swipeGesture)
        .navigationBarTitleDisplayMode(.inline)
    }

    /// The big character on a card. `.id` tells SwiftUI it is a new view when the item changes,
    /// which is what makes the slide transition run.
    private var characterCard: some View {
        KidsCard {
            Text(viewModel.item.character)
                .font(.system(size: characterSize, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.color(for: viewModel.item.category))
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .id(viewModel.item.id)
        .transition(.lessonSlide(forward: viewModel.isMovingForward))
    }

    /// The emoji and example word, e.g. "🍎 Apple". VoiceOver reads only the word.
    private var wordRow: some View {
        HStack(spacing: Theme.Spacing.medium) {
            Text(viewModel.item.emoji)
                .accessibilityHidden(true)
            Text(viewModel.item.word)
                .bold()
        }
        .font(.largeTitle)
        .minimumScaleFactor(0.5)
        .id(viewModel.item.id)
        .transition(.lessonSlide(forward: viewModel.isMovingForward))
    }

    /// Previous arrow, speak button and next arrow.
    private var controls: some View {
        HStack(spacing: Theme.Spacing.large) {
            iconButton("chevron.left", label: "Previous", action: showPrevious)
                .disabled(!viewModel.hasPrevious)
                .opacity(viewModel.hasPrevious ? 1 : 0.3)
            // Hidden when the device has no voice for this language (text only).
            if viewModel.canSpeak {
                iconButton("speaker.wave.2.fill", label: "Listen", action: viewModel.speak)
            }
            iconButton("chevron.right", label: "Next", action: showNext)
                .disabled(!viewModel.hasNext)
                .opacity(viewModel.hasNext ? 1 : 0.3)
        }
    }

    /// A round 60-point button with an SF Symbol and a VoiceOver label.
    private func iconButton(_ systemImage: String, label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title)
                .bold()
                // The circle has a fixed size, so the icon stops growing at this text size to stay inside it.
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .foregroundStyle(.white)
                .frame(width: Theme.minTouchTarget, height: Theme.minTouchTarget)
                .background(Theme.primary, in: Circle())
        }
        .bouncyPress()
        .accessibilityLabel(label)
    }

    /// Opens the tracing screen for the current item.
    private var traceButton: some View {
        NavigationLink(value: Route.tracing(viewModel.item)) {
            Label("Trace it", systemImage: "hand.draw.fill")
                .font(.title2)
                .bold()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget)
                .background(Theme.success, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        }
        .bouncyPress()
    }

    /// A sideways drag: swipe left for the next character, swipe right for the previous one.
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { drag in
                if drag.translation.width < -50 {
                    showNext()
                } else if drag.translation.width > 50 {
                    showPrevious()
                }
            }
    }

    /// Changes to the next item inside an animation so the slide transition plays.
    private func showNext() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewModel.goToNext()
        }
    }

    /// Changes to the previous item inside an animation so the slide transition plays.
    private func showPrevious() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewModel.goToPrevious()
        }
    }
}

#Preview {
    NavigationStack {
        LessonDetailView(item: LearningContent.englishLetters[0])
    }
}
