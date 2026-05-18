import SwiftUI
import TrainingCore

struct WorkoutExerciseSectionView: View {
    @ObservedObject var viewModel: WorkoutSessionViewModel
    let workoutExercise: WorkoutExercise

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise title + delete button
            HStack {
                Text(workoutExercise.exerciseNameSnapshot)
                    .font(.largeTitle)
                    .fontWeight(.medium)

                Spacer()

                Button(role: .destructive) {
                    viewModel.removeExercise(workoutExercise.id)
                } label: {
                    Image(systemName: "trash")
                }
            }

            // Column headers
            headerRow

            // Sets
            ForEach(Array(workoutExercise.sets.enumerated()), id: \.element.id) { index, set in
                WorkoutSetRowView(
                    setNumber: index + 1,
                    set: set,
                    weight: Binding(
                        get: {
                            currentSetValue(setID: set.id)?.weight ?? 0
                        },
                        set: { newValue in
                            viewModel.updateSetWeight(
                                workoutExerciseID: workoutExercise.id,
                                setID: set.id,
                                weight: newValue
                            )
                        }
                    ),
                    reps: Binding(
                        get: {
                            currentSetValue(setID: set.id)?.reps ?? 0
                        },
                        set: { newValue in
                            viewModel.updateSetReps(
                                workoutExerciseID: workoutExercise.id,
                                setID: set.id,
                                reps: newValue
                            )
                        }
                    ),
                    onToggleComplete: {
                        viewModel.toggleSetCompleted(
                            workoutExerciseID: workoutExercise.id,
                            setID: set.id
                        )
                    },
                    onDelete: {
                        viewModel.removeSet(
                            from: workoutExercise.id,
                            setID: set.id
                        )
                    }
                )
            }

            // Add set button
            Button {
                let previous = workoutExercise.sets.last
                viewModel.addSet(
                    to: workoutExercise.id,
                    weight: previous?.weight ?? 0,
                    reps: previous?.reps ?? 0,
                    previousWeight: previous?.weight,
                    previousReps: previous?.reps
                )
            } label: {
                Text("add set")
                    .font(.title3)
                    .frame(maxWidth: 160)
            }
            .buttonStyle(.bordered)
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }

    private var headerRow: some View {
        HStack {
            Text("set")
                .frame(width: 40, alignment: .leading)

            Text("previous")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("kg")
                .frame(width: 70)

            Text("reps")
                .frame(width: 70)

            Color.clear
                .frame(width: 44)
        }
        .font(.title3)
        .foregroundColor(.primary)
    }

    private func currentSetValue(setID: UUID) -> WorkoutSet? {
        viewModel.session.exercises
            .first(where: { $0.id == workoutExercise.id })?
            .sets.first(where: { $0.id == setID })
    }
}
