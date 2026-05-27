import SwiftUI

public struct CreateExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ExerciseDraft()

    //keeps the current exercise names so the form can block duplicate names before saving
    private let existingExerciseNames: [String]

    public let onSave: (ExerciseDraft) -> Void

    //creates the view with a callback that receives the finished exercise draft
    public init(_ onSave: @escaping (ExerciseDraft) -> Void) {
        self.existingExerciseNames = []
        self.onSave = onSave
    }

    //creates the view with existing names so duplicate exercise names cannot be saved
    public init(existingExerciseNames: [String], _ onSave: @escaping (ExerciseDraft) -> Void) {
        self.existingExerciseNames = existingExerciseNames
        self.onSave = onSave
    }

    //normalises the typed name once so empty and duplicate checks use the same text
    private var trimmedName: String {
        draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    //compares names without caring about case or extra whitespace
    private var isDuplicateName: Bool {
        existingExerciseNames.contains {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
                .localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }
    }

    //only enables save when the exercise has a new non-empty name
    private var canSave: Bool {
        !trimmedName.isEmpty && !isDuplicateName
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $draft.name)
                    //shows the reason save is disabled instead of silently blocking the user
                    if isDuplicateName {
                        Text("An exercise with this name already exists.")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
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
                        guard canSave else { return }
                        onSave(draft)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
