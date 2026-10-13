//
//  ParentAreaView.swift
//  LittleLearners
//

import SwiftUI
import SwiftData

/// The entry to the parent area. It shows the parental gate first and switches to the
/// dashboard once the maths question is answered correctly.
/// The gate's state lives here, so the area is locked again every time it is opened.
struct ParentAreaView: View {
    /// The selected child, put in the environment by `RootView`. The dashboard shows this child's progress.
    @Environment(ChildProfile.self) private var profile

    /// The gate logic. `isUnlocked` decides which screen is shown.
    @State private var gate = ParentalGateViewModel()

    var body: some View {
        if gate.isUnlocked {
            ParentDashboardView(profile: profile)
        } else {
            ParentalGateView(viewModel: gate)
        }
    }
}

#Preview {
    NavigationStack {
        ParentAreaView()
    }
    .modelContainer(PreviewData.container)
    .environment(PreviewData.profile)
}
