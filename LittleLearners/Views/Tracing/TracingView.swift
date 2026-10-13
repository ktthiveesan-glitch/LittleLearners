//
//  TracingView.swift
//  LittleLearners
//

import SwiftUI
import SwiftData

/// The tracing screen: a star counter, the drawing canvas, a message, and Clear and Check buttons.
/// A correct tracing plays confetti and sends a star flying up to the counter.
/// A wrong one shows "Try again!" and gently shakes the canvas.
struct TracingView: View {
    /// `.compact` when the screen is short, i.e. an iPhone in landscape.
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    /// The selected child, put in the environment by `RootView`. This child gets the star and the attempt.
    @Environment(ChildProfile.self) private var profile

    /// Holds the drawing and does the checking.
    @State private var viewModel: TracingViewModel

    /// The number in the counter. Kept apart from the saved total so it only goes up when the flying star lands.
    @State private var displayedStars = 0

    /// True while confetti is falling.
    @State private var showsConfetti = false

    /// True while the big celebration star is on screen.
    @State private var showsFlyingStar = false

    /// False = the star sits in the middle of the screen. True = it has moved to the counter.
    @State private var starIsAtCounter = false

    /// The user's text size setting.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Size of the celebration star. Grows with the user's text size.
    @ScaledMetric private var flyingStarSize: CGFloat = 90

    init(item: LearningItem) {
        _viewModel = State(initialValue: TracingViewModel(item: item))
    }

    var body: some View {
        // Side by side when the screen is short (landscape iPhone), stacked otherwise.
        let isSideBySide = verticalSizeClass == .compact
        let layout = isSideBySide
            ? AnyLayout(HStackLayout(spacing: Theme.Spacing.large))
            : AnyLayout(VStackLayout(spacing: Theme.Spacing.large))

        VStack(spacing: Theme.Spacing.medium) {
            StarCounter(stars: displayedStars)
                .frame(maxWidth: .infinity, alignment: .trailing)
            layout {
                canvasCard
                    // Side by side: the canvas is sized first (a square as tall as the screen allows).
                    .layoutPriority(isSideBySide ? 1 : 0)
                VStack(spacing: Theme.Spacing.large) {
                    message
                    buttons
                }
                // Stacked: the message and buttons get the height their text needs first,
                // and the canvas then uses the space that is left.
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(isSideBySide ? 0 : 1)
            }
        }
        .overlay { flyingStar }
        .padding(Theme.Spacing.large)
        .frame(maxWidth: 800, maxHeight: .infinity)
        .frame(maxWidth: .infinity)
        .background(Theme.background)
        .overlay {
            if showsConfetti {
                ConfettiView()
            }
        }
        .navigationTitle("Trace \(viewModel.item.character)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { displayedStars = profile.stars }
    }

    /// The square white card that holds the canvas. It shakes when the answer is wrong.
    private var canvasCard: some View {
        TracingCanvas(viewModel: viewModel)
            .aspectRatio(1, contentMode: .fit)
            // Tells the view model how big the canvas is, at first and after rotation.
            .onGeometryChange(for: CGSize.self) { $0.size } action: { viewModel.canvasSizeChanged(to: $0) }
            .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.large))
            .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
            // No more drawing after a correct answer, until the child taps Clear.
            .allowsHitTesting(viewModel.status != .correct)
            .modifier(ShakeEffect(shakes: CGFloat(viewModel.wrongCount)))
            .animation(.linear(duration: 0.5), value: viewModel.wrongCount)
            .accessibilityElement()
            .accessibilityLabel("Trace \(viewModel.item.character)")
            .accessibilityHint("Draw over the dotted lines")
    }

    /// One line of feedback that changes with the status.
    @ViewBuilder
    private var message: some View {
        Group {
            switch viewModel.status {
            case .drawing:
                Text("Draw over the dotted lines")
                    .foregroundStyle(.secondary)
            case .checking:
                ProgressView()
            case .correct:
                Text("Well done!")
                    .foregroundStyle(Theme.success)
            case .wrong:
                Text("Try again!")
                    .foregroundStyle(Theme.accent)
            }
        }
        .font(.title2)
        .bold()
        .multilineTextAlignment(.center)
        // A fixed minimum height stops the layout jumping when the message changes.
        .frame(minHeight: Theme.minTouchTarget)
    }

    /// The Clear and Check buttons, side by side (stacked with very large text).
    private var buttons: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: Theme.Spacing.medium))
            : AnyLayout(HStackLayout(spacing: Theme.Spacing.medium))
        return layout {
            Button(action: viewModel.clear) {
                Label("Clear", systemImage: "eraser.fill")
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget)
                    .background(Theme.secondary.opacity(0.25), in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
            }
            .bouncyPress()

            Button(action: checkTapped) {
                Label("Check", systemImage: "checkmark")
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget)
                    .background(Theme.success, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
            }
            .bouncyPress()
            .disabled(!viewModel.canCheck)
            .opacity(viewModel.canCheck ? 1 : 0.5)
        }
        .font(.title3)
        .bold()
    }

    /// The celebration star. Changing the alignment inside an animation makes it fly
    /// from the centre to the top right corner, where the star counter is.
    @ViewBuilder
    private var flyingStar: some View {
        if showsFlyingStar {
            Image(systemName: "star.fill")
                .font(.system(size: flyingStarSize))
                .foregroundStyle(.yellow)
                .shadow(radius: 4)
                .scaleEffect(starIsAtCounter ? 0.3 : 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: starIsAtCounter ? .topTrailing : .center)
                .transition(.scale)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    /// Runs the check and, if it is correct, the celebration.
    private func checkTapped() {
        Task {
            await viewModel.check(profile: profile)
            // Tell VoiceOver users the result, because they cannot see the message appear.
            let isCorrect = viewModel.status == .correct
            let spokenResult = AppLanguage.current.text(isCorrect ? "Well done!" : "Try again!")
            AccessibilityNotification.Announcement(spokenResult).post()
            if isCorrect {
                await celebrate()
            }
        }
    }

    /// The success sequence: confetti, a star pops up, flies to the counter, and the counter goes up.
    private func celebrate() async {
        showsConfetti = true
        starIsAtCounter = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            showsFlyingStar = true
        }
        try? await Task.sleep(for: .seconds(0.8))

        withAnimation(.easeInOut(duration: 0.7)) {
            starIsAtCounter = true
        }
        try? await Task.sleep(for: .seconds(0.7))

        showsFlyingStar = false
        withAnimation {
            displayedStars = profile.stars
        }
        try? await Task.sleep(for: .seconds(2))
        showsConfetti = false
    }
}

#Preview {
    NavigationStack {
        TracingView(item: LearningContent.englishLetters[0])
    }
    .modelContainer(PreviewData.container)
    .environment(PreviewData.profile)
}
