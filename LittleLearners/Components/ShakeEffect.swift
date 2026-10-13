//
//  ShakeEffect.swift
//  LittleLearners
//

import SwiftUI

/// Moves a view gently left and right. Used to say "not quite" in a friendly way.
///
/// How to use: keep a counter, apply `.modifier(ShakeEffect(shakes: CGFloat(counter)))`
/// and animate the counter going up by one. SwiftUI then feeds every value between the old
/// and new number into `animatableData`, and the sine wave below turns that into a wobble.
struct ShakeEffect: GeometryEffect {
    /// How far the view moves to each side, in points.
    var distance: CGFloat = 8

    /// Number of wobbles for each step of the counter.
    var wobblesPerShake: CGFloat = 3

    /// The animated counter value.
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = distance * sin(shakes * .pi * 2 * wobblesPerShake)
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}
