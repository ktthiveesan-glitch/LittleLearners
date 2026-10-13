//
//  SlideTransition.swift
//  LittleLearners
//

import SwiftUI

extension AnyTransition {
    /// The transition used when the lesson screen changes character.
    /// The new character slides in from the right when moving forward and from the left
    /// when moving back, while the old character fades out.
    static func lessonSlide(forward: Bool) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: forward ? .trailing : .leading).combined(with: .opacity),
            removal: .opacity
        )
    }
}
