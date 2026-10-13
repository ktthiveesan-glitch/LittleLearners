//
//  TracingCanvas.swift
//  LittleLearners
//

import SwiftUI

/// The drawing area. It shows the dotted guide character and, on top, the lines the child
/// draws with a finger. The finger movement is read with a `DragGesture`.
///
/// The canvas reads the drawing straight from the view model. Because only this view reads `strokes`,
/// only this view is redrawn while the finger moves; the rest of the tracing screen is left alone.
struct TracingCanvas: View {
    /// Owns the guide outline and the child's strokes.
    let viewModel: TracingViewModel

    /// True while the finger is down. Tells us whether a drag point starts a new stroke.
    @State private var isDrawing = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // The guide: a faint filled letter with a dotted outline.
                viewModel.guidePath.fill(Color.gray.opacity(0.15))
                viewModel.guidePath.stroke(Color.gray, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [1, 9]))

                // The child's drawing, scaled from fractions up to the real canvas size.
                Path(strokes: viewModel.strokes)
                    .applying(CGAffineTransform(scaleX: geometry.size.width, y: geometry.size.height))
                    .stroke(Theme.accent,
                            style: StrokeStyle(lineWidth: viewModel.lineWidth, lineCap: .round, lineJoin: .round))
            }
            // Makes the whole square react to touches, not only the drawn parts.
            .contentShape(Rectangle())
            .gesture(drawGesture(in: geometry.size))
        }
    }

    /// Records the finger position. `minimumDistance: 0` means even a tap leaves a dot.
    private func drawGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                guard size.width > 0, size.height > 0 else { return }
                // Turn the position into a fraction of the canvas, and keep it between 0 and 1
                // even if the finger slides off the edge.
                let point = CGPoint(x: min(max(drag.location.x / size.width, 0), 1),
                                    y: min(max(drag.location.y / size.height, 0), 1))
                viewModel.addPoint(point, startsNewStroke: !isDrawing)
                isDrawing = true
            }
            .onEnded { _ in
                isDrawing = false
            }
    }
}

#Preview {
    let viewModel = TracingViewModel(item: LearningContent.englishLetters[0])
    return TracingCanvas(viewModel: viewModel)
        .frame(width: 300, height: 300)
        .background(Theme.card)
        .onAppear { viewModel.canvasSizeChanged(to: CGSize(width: 300, height: 300)) }
}
