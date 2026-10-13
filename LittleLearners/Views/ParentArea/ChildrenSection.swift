//
//  ChildrenSection.swift
//  LittleLearners
//

import SwiftUI
import SwiftData

/// The "Children" section of the parent dashboard: a row for every child.
/// Tapping a row asks the dashboard to open the edit sheet for that child.
/// It lives in the parent area, so it is only reachable after the parental gate.
struct ChildrenSection: View {
    /// All saved children, oldest first.
    @Query(sort: \ChildProfile.createdAt) private var profiles: [ChildProfile]

    /// Called with the child whose row was tapped.
    let onEdit: (ChildProfile) -> Void

    var body: some View {
        Section("Children") {
            ForEach(profiles) { profile in
                Button {
                    onEdit(profile)
                } label: {
                    HStack(spacing: Theme.Spacing.medium) {
                        Text(profile.avatar)
                            .font(.title)
                            .accessibilityHidden(true)
                        Text(profile.name)
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                        Spacer()
                        Image(systemName: "pencil")
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                    .frame(minHeight: Theme.minTouchTarget)
                    .contentShape(Rectangle())
                }
                .accessibilityHint("Edit child")
            }
        }
    }
}
