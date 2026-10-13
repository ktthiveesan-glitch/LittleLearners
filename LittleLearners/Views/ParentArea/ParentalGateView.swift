//
//  ParentalGateView.swift
//  LittleLearners
//

import SwiftUI

/// The lock in front of the parent area: a sum such as "7 + 5" and a number pad.
/// Only the right answer opens the dashboard. A wrong answer shakes the screen and asks a new sum.
struct ParentalGateView: View {
    /// The gate logic, owned by `ParentAreaView`.
    let viewModel: ParentalGateViewModel

    /// Three buttons per row, like a phone keypad.
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Theme.Spacing.medium), count: 3)

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.large) {
                Image(systemName: "lock.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Theme.primary)
                    .accessibilityHidden(true)
                Text("Parents only")
                    .font(.largeTitle)
                    .bold()
                Text("Answer the question to continue")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                question
                keypad
            }
            .padding(Theme.Spacing.large)
            // Keeps the keypad a comfortable size on iPad and in landscape.
            .frame(maxWidth: 380)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.background)
        .navigationTitle("Parents")
        .navigationBarTitleDisplayMode(.inline)
        // Tell VoiceOver users when the answer was wrong, because they cannot see the shake.
        .onChange(of: viewModel.wrongCount) {
            AccessibilityNotification.Announcement(AppLanguage.current.text("Try again!")).post()
        }
    }

    /// The sum and the box that shows what has been typed. It shakes after a wrong answer.
    private var question: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Text("What is \(viewModel.firstNumber) + \(viewModel.secondNumber)?")
                .font(.title)
                .bold()
            Text(verbatim: viewModel.typedAnswer.isEmpty ? " " : viewModel.typedAnswer)
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
                .accessibilityLabel("Your answer")
                .accessibilityValue(Text(verbatim: viewModel.typedAnswer))
        }
        .modifier(ShakeEffect(shakes: CGFloat(viewModel.wrongCount)))
        .animation(.linear(duration: 0.5), value: viewModel.wrongCount)
    }

    /// The number pad: 1 to 9, then delete, 0 and OK.
    private var keypad: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
            ForEach(1...9, id: \.self) { digit in
                digitKey(digit)
            }
            key(color: Theme.secondary, action: viewModel.deleteLastDigit) {
                Image(systemName: "delete.left.fill")
            }
            .accessibilityLabel("Delete")

            digitKey(0)

            key(color: Theme.success, action: viewModel.submit) {
                Text("OK")
            }
            .disabled(!viewModel.canSubmit)
            .opacity(viewModel.canSubmit ? 1 : 0.5)
        }
    }

    /// A key that types one digit.
    private func digitKey(_ digit: Int) -> some View {
        key(color: Theme.primary, action: { viewModel.typeDigit(digit) }) {
            Text(verbatim: "\(digit)")
        }
    }

    /// One keypad key with a tinted background. All keys are at least 60 points tall.
    private func key<Label: View>(color: Color, action: @escaping () -> Void,
                                  @ViewBuilder label: () -> Label) -> some View {
        Button(action: action) {
            label()
                .font(.title)
                .bold()
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget)
                .background(color.opacity(0.25), in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        }
        .bouncyPress()
    }
}

#Preview {
    NavigationStack {
        ParentalGateView(viewModel: ParentalGateViewModel())
    }
}
