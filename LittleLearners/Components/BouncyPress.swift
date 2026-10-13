//
//  BouncyPress.swift
//  LittleLearners
//

import SwiftUI

/// A button style that shrinks the button a little while it is pressed and lets it
/// spring back when the finger lifts. It gives children clear feedback that their tap worked.
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

extension View {
    /// Adds the bouncy press effect to a `Button` or `NavigationLink`.
    /// Usage: `Button("Go") { ... }.bouncyPress()`
    func bouncyPress() -> some View {
        buttonStyle(BouncyButtonStyle())
    }
}
