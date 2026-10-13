//
//  ProfileEditView.swift
//  LittleLearners
//

import SwiftUI
import SwiftData

/// A sheet where a parent changes one child's name and avatar, or deletes the child.
/// Deleting asks for confirmation first, because it also deletes that child's progress.
struct ProfileEditView: View {
    @Environment(\.modelContext) private var modelContext

    /// Closes the sheet.
    @Environment(\.dismiss) private var dismiss

    /// Holds the edited name and avatar until Save is tapped.
    @State private var viewModel: ProfileEditViewModel

    /// True while the "are you sure?" alert for delete is showing.
    @State private var showsDeleteAlert = false

    init(profile: ChildProfile) {
        _viewModel = State(initialValue: ProfileEditViewModel(profile: profile))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $viewModel.name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .frame(minHeight: Theme.minTouchTarget)
                }
                Section("Pick your picture") {
                    AvatarPicker(selection: $viewModel.avatar)
                        .padding(.vertical, Theme.Spacing.small)
                }
                Section {
                    Button("Delete child", role: .destructive) {
                        showsDeleteAlert = true
                    }
                    .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget, alignment: .leading)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Edit child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save()
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .alert("Delete \(viewModel.profile.name)?", isPresented: $showsDeleteAlert) {
                Button("Delete", role: .destructive) {
                    // Close the sheet first, then delete, so no screen is still showing the deleted child.
                    dismiss()
                    viewModel.delete(in: modelContext)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All of this child's stars, badges and tracing history will be deleted. This cannot be undone.")
            }
        }
    }
}

#Preview {
    ProfileEditView(profile: PreviewData.profile)
        .modelContainer(PreviewData.container)
}
