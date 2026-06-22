import SwiftUI
import TrainingCore

struct RoutineExercisePickerView: View {
    let allExercises: [Exercise]
    let existingTemplates: [RoutineExerciseTemplate]
    let onSave: (RoutineExerciseTemplate) -> Void
    let onFinish: () -> Void

    @State private var searchText = ""

    //filters the exercise catalog while keeping routine creation searchable
    private var filteredExercises: [Exercise] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return allExercises
        }

        return allExercises.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredExercises) { exercise in
                NavigationLink {
                    RoutineExerciseDetailFormView(
                        exercise: exercise,
                        template: template(for: exercise),
                        onDone: { template in
                            onSave(template)
                            onFinish()
                        }
                    )
                } label: {
                    HStack {
                        Text(exercise.name)
                            .foregroundColor(.primary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Choose Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        onFinish()
                    }
                }
            }
        }
    }

    //uses an existing template when editing, otherwise starts a new exercise with sensible defaults
    private func template(for exercise: Exercise) -> RoutineExerciseTemplate {
        existingTemplates.first { $0.exerciseID == exercise.id } ??
            RoutineExerciseTemplate(exerciseID: exercise.id, targetSets: 3, targetReps: 10)
    }
}
