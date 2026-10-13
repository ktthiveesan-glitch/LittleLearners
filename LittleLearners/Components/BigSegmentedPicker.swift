//
//  BigSegmentedPicker.swift
//  LittleLearners
//

import SwiftUI

/// A segmented picker made for small fingers: a row of big buttons where exactly one is selected.
/// The system segmented picker is only about 32 points tall; every button here is at least 60.
/// With very large text sizes the buttons are stacked instead, so no label is cut off.
struct BigSegmentedPicker<Value: Hashable>: View {
    /// The choices, in the order they are shown.
    let options: [Value]

    /// Gives the text for one choice. The text is shown exactly as given (not translated).
    let title: (Value) -> String

    /// The selected choice.
    @Binding var selection: Value

    /// The user's text size setting.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: Theme.Spacing.small))
            : AnyLayout(HStackLayout(spacing: Theme.Spacing.small))

        layout {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection
                Button {
                    selection = option
                } label: {
                    Text(verbatim: title(option))
                        .font(.headline)
                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                        .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget)
                        .background(isSelected ? Theme.primary : Theme.card,
                                    in: RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
                }
                .bouncyPress()
                // VoiceOver says "selected" for the chosen button.
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

#Preview {
    @Previewable @State var script = Script.english
    BigSegmentedPicker(options: Script.allCases, title: \.displayName, selection: $script)
        .padding()
        .background(Theme.background)
}
