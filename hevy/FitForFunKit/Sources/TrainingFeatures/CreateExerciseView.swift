import SwiftUI
import TrainingCore

public struct CreateExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ExerciseDraft()

    public let onSave: (ExerciseDraft) -> Void

    public init(_ onSave: @escaping (ExerciseDraft) -> Void) {
        self.onSave = onSave
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $draft.name)
                    TextField("Equipment (optional)", text: $draft.equipment)
                }

                Section("Muscles") {
                    TextField("Primary muscles (comma separated)", text: $draft.primaryMusclesText)
                    TextField("Secondary muscles (comma separated)", text: $draft.secondaryMusclesText)
                }
            }
            .navigationTitle("Create Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(draft)
                        dismiss()
                    }
                    .disabled(draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
