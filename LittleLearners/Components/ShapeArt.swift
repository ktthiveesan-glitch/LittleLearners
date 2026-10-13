//
//  ShapeArt.swift
//  LittleLearners
//

import SwiftUI

/// Gives the drawable shape and the colour for each shape item in the shapes game.
enum ShapeArt {
    /// The SwiftUI shape for a shape item. `AnyShape` lets one function return different shape types.
    static func shape(for item: LearningItem) -> AnyShape {
        switch item.id {
        case "shape-circle": AnyShape(Circle())
        case "shape-square": AnyShape(Rectangle())
        case "shape-triangle": AnyShape(TriangleShape())
        case "shape-rectangle": AnyShape(WideRectangleShape())
        case "shape-star": AnyShape(StarShape())
        case "shape-heart": AnyShape(HeartShape())
        default: AnyShape(Circle())
        }
    }

    /// Each shape has its own colour so it is easy to tell them apart.
    static func color(for item: LearningItem) -> Color {
        switch item.id {
        case "shape-circle": Theme.primary
        case "shape-square": Theme.secondary
        case "shape-triangle": Theme.success
        case "shape-rectangle": .purple
        case "shape-star": .yellow
        case "shape-heart": Theme.accent
        default: Theme.primary
        }
    }
}

/// A triangle with its point at the top.
struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// A rectangle that is wider than it is tall, so it looks different from the square.
struct WideRectangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(rect.insetBy(dx: 0, dy: rect.height * 0.22))
    }
}

/// A five-pointed star. It walks round a circle, switching between an outer point and an inner corner.
struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.42
        var path = Path()
        for step in 0..<10 {
            let radius = step.isMultiple(of: 2) ? outerRadius : innerRadius
            // Start at the top (-90°) and move 36° each step.
            let angle = CGFloat(Angle.degrees(Double(step) * 36 - 90).radians)
            let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            if step == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

/// A heart drawn with four curves: up the left side, over the two bumps, and down the right side.
struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        /// Turns fractions (0 to 1) into a real point inside `rect`.
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }
        var path = Path()
        path.move(to: point(0.5, 0.95))
        path.addCurve(to: point(0, 0.3), control1: point(0.2, 0.75), control2: point(0, 0.55))
        path.addCurve(to: point(0.5, 0.22), control1: point(0, -0.05), control2: point(0.45, 0))
        path.addCurve(to: point(1, 0.3), control1: point(0.55, 0), control2: point(1, -0.05))
        path.addCurve(to: point(0.5, 0.95), control1: point(1, 0.55), control2: point(0.8, 0.75))
        path.closeSubpath()
        return path
    }
}
