//
//  ShapesGameView.swift
//  LittleLearners
//

import SwiftUI
import SwiftData

/// The shapes game. Dotted outlines sit at the top and coloured shapes at the bottom.
/// The child drags each shape onto the outline that matches it.
struct ShapesGameView: View {
    /// The selected child, put in the environment by `RootView`. Their progress is saved when a shape is placed.
    @Environment(ChildProfile.self) private var profile

    /// `.compact` when the screen is short, i.e. an iPhone in landscape.
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    /// The game logic.
    @State private var viewModel = ShapesGameViewModel()

    /// Three shapes per row, in both the outlines and the tray.
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Theme.Spacing.medium), count: 3)

    /// The name of the shared coordinate space, so outline and shape positions can be compared.
    private let gameSpace = "game"

    var body: some View {
        // Outlines and tray side by side when the screen is short (landscape iPhone), stacked otherwise.
        let layout = verticalSizeClass == .compact
            ? AnyLayout(HStackLayout(spacing: Theme.Spacing.large))
            : AnyLayout(VStackLayout(spacing: Theme.Spacing.large))

        VStack(spacing: Theme.Spacing.medium) {
            header
                // The instruction gets the height its text needs before the grids are sized.
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
            layout {
                targetGrid
                pieceGrid
            }
            // The two grids together have a known shape (about 3 wide to 4 tall when stacked,
            // 3 wide to 1 tall side by side). Fitting that shape into the free space shrinks the
            // shapes when the screen is short, so nothing runs off the bottom on iPad or with big text.
            .aspectRatio(verticalSizeClass == .compact ? 3.1 : 0.72, contentMode: .fit)
        }
        .padding(Theme.Spacing.large)
        .frame(maxWidth: 800, maxHeight: .infinity)
        .frame(maxWidth: .infinity)
        .coordinateSpace(.named(gameSpace))
        .background(Theme.background)
        .overlay {
            if viewModel.isComplete {
                ConfettiView()
            }
        }
        .navigationTitle(Text(LearningCategory.shapes.title))
        .navigationBarTitleDisplayMode(.inline)
        // Tell VoiceOver users when the game is finished.
        .onChange(of: viewModel.isComplete) { _, isComplete in
            if isComplete {
                AccessibilityNotification.Announcement(AppLanguage.current.text("You did it!")).post()
            }
        }
    }

    /// The instruction, or "You did it!" and a Play again button when the game is finished.
    @ViewBuilder
    private var header: some View {
        if viewModel.isComplete {
            HStack(spacing: Theme.Spacing.medium) {
                Text("You did it!")
                    .font(.title)
                    .bold()
                    .foregroundStyle(Theme.success)
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        viewModel.playAgain()
                    }
                } label: {
                    Label("Play again", systemImage: "arrow.counterclockwise")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, Theme.Spacing.medium)
                        .frame(minHeight: Theme.minTouchTarget)
                        .background(Theme.primary, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
                }
                .bouncyPress()
            }
        } else {
            Text("Drag each shape to its outline")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .frame(minHeight: Theme.minTouchTarget)
        }
    }

    /// The dotted outlines.
    private var targetGrid: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
            ForEach(viewModel.targets) { target in
                let shape = ShapeArt.shape(for: target)
                ZStack {
                    shape.fill(Color.gray.opacity(0.15))
                    shape.stroke(Color.gray, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 8]))
                }
                .aspectRatio(1, contentMode: .fit)
                // Remember where this outline is, so a drop can be checked against it.
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(gameSpace)) } action: { frame in
                    viewModel.targetFrames[target.id] = frame
                }
                .accessibilityElement()
                .accessibilityLabel("\(target.word) outline")
            }
        }
    }

    /// The tray of coloured shapes.
    private var pieceGrid: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
            ForEach(viewModel.pieces) { piece in
                // An invisible square marks the shape's starting place. The shape itself is drawn
                // on top with an offset, so moving it never changes the layout.
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(gameSpace)) } action: { frame in
                        viewModel.pieceFrames[piece.id] = frame
                    }
                    .overlay { pieceView(for: piece) }
                    // The shape being dragged is drawn above the others.
                    .zIndex(viewModel.isDragging(piece) ? 1 : 0)
            }
        }
    }

    /// One draggable shape.
    private func pieceView(for piece: LearningItem) -> some View {
        ShapeArt.shape(for: piece)
            .fill(ShapeArt.color(for: piece))
            .shadow(color: .black.opacity(viewModel.isMatched(piece) ? 0 : 0.2), radius: 4, y: 2)
            .scaleEffect(viewModel.isDragging(piece) ? 1.1 : 1)
            .offset(viewModel.offset(for: piece))
            .gesture(dragGesture(for: piece))
            // A placed shape can no longer be moved.
            .allowsHitTesting(!viewModel.isMatched(piece))
            .accessibilityElement()
            .accessibilityLabel(Text(piece.word))
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Double tap to put it on its outline")
            // VoiceOver users cannot drag, so a double tap places the shape.
            .accessibilityAction {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    viewModel.place(piece, profile: profile)
                }
            }
    }

    /// Follows the finger, then decides what happens on release.
    private func dragGesture(for piece: LearningItem) -> some Gesture {
        DragGesture()
            .onChanged { drag in
                viewModel.dragChanged(piece, translation: drag.translation)
            }
            .onEnded { drag in
                // Use the exact position where the finger lifted.
                viewModel.dragChanged(piece, translation: drag.translation)
                // Correct: a quick, firm spring that "snaps" into place.
                // Wrong: a looser spring, so the shape bounces as it returns to the tray.
                let snap = Animation.spring(response: 0.35, dampingFraction: 0.7)
                let bounceBack = Animation.spring(response: 0.5, dampingFraction: 0.45)
                withAnimation(viewModel.isOverOwnTarget(piece) ? snap : bounceBack) {
                    viewModel.dragEnded(piece, profile: profile)
                }
            }
    }
}

#Preview {
    NavigationStack {
        ShapesGameView()
    }
    .modelContainer(PreviewData.container)
    .environment(PreviewData.profile)
}
