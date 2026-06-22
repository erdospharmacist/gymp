import SwiftUI
import TrainingCore

struct WorkoutExerciseSectionView: View {
    @ObservedObject var viewModel: WorkoutSessionViewModel
    let workoutExercise: WorkoutExercise
    let canMoveUp: Bool
    let canMoveDown: Bool
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise title + delete button
            HStack {
                Text(workoutExercise.exerciseNameSnapshot)
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                //moves exercise blocks within the active workout without changing the exercise itself
                Button {
                    onMoveUp()
                } label: {
                    Image(systemName: "chevron.up")
                }
                .disabled(!canMoveUp)

                Button {
                    onMoveDown()
                } label: {
                    Image(systemName: "chevron.down")
                }
                .disabled(!canMoveDown)

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
                viewModel.addSet(to: workoutExercise.id)
            } label: {
                Text("add set")
                    .font(.title3)
                    .frame(maxWidth: 160)
            }
            .buttonStyle(.bordered)
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
        .font(.subheadline)
        .foregroundColor(.primary)
    }

    //looks up the freshest set value from the view model so bindings stay in sync
    private func currentSetValue(setID: UUID) -> WorkoutSet? {
        viewModel.session.exercises
            .first(where: { $0.id == workoutExercise.id })?
            .sets.first(where: { $0.id == setID })
    }
}
