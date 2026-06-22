import SwiftUI
import TrainingCore

struct RoutineExerciseDetailFormView: View {
    let exercise: Exercise
    let onDone: (RoutineExerciseTemplate) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var targetSets: Int
    @State private var targetReps: Int
    @State private var notes: String

    //creates the routine exercise editor from the current template values
    init(
        exercise: Exercise,
        template: RoutineExerciseTemplate,
        onDone: @escaping (RoutineExerciseTemplate) -> Void
    ) {
        self.exercise = exercise
        self.onDone = onDone
        _targetSets = State(initialValue: max(template.targetSets, 1))
        _targetReps = State(initialValue: max(template.targetReps ?? 10, 1))
        _notes = State(initialValue: template.notes)
    }

    private var primaryMusclesText: String {
        exercise.primaryMuscles.isEmpty ? "None" : exercise.primaryMuscles.joined(separator: ", ")
    }

    private var secondaryMusclesText: String {
        exercise.secondaryMuscles.isEmpty ? "None" : exercise.secondaryMuscles.joined(separator: ", ")
    }

    var body: some View {
        Form {
            Section("Trains") {
                LabeledContent("Primary", value: primaryMusclesText)
                LabeledContent("Secondary", value: secondaryMusclesText)
            }

            Section("Routine Exercise") {
                Stepper("Sets: \(targetSets)", value: $targetSets, in: 1...20)
                Stepper("Reps: \(targetReps)", value: $targetReps, in: 1...100)
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    onDone(
                        RoutineExerciseTemplate(
                            exerciseID: exercise.id,
                            targetSets: targetSets,
                            targetReps: targetReps,
                            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                    )
                    dismiss()
                }
            }
        }
    }
}
