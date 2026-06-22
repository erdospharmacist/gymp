import SwiftUI
import Combine
import TrainingCore

struct WorkoutSessionView: View {
    @StateObject private var viewModel: WorkoutSessionViewModel
    let allExercises: [Exercise]

    @Environment(\.dismiss) private var dismiss
    @State private var showingExercisePicker = false
    @State private var showingDiscardAlert = false

    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    //creates the workout screen with its session view model and exercise catalog
    init(session: WorkoutSession, allExercises: [Exercise]) {
        _viewModel = StateObject(wrappedValue: WorkoutSessionViewModel(session: session))
        self.allExercises = allExercises
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                WorkoutSummaryHeaderView(
                    title: viewModel.session.name,
                    duration: durationText,
                    volume: viewModel.session.totalVolume.kgText,
                    totalSets: viewModel.session.totalSets,
                    onFinish: {
                        viewModel.finishWorkout()
                        dismiss()
                    }
                )

                if viewModel.session.exercises.isEmpty {
                    VStack(spacing: 12) {
                        Text("No exercises yet")
                            .font(.title3)
                            .fontWeight(.medium)

                        Text("Tap “add exercise” to start building this workout.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(Array(viewModel.session.exercises.enumerated()), id: \.element.id) { index, workoutExercise in
                        WorkoutExerciseSectionView(
                            viewModel: viewModel,
                            workoutExercise: workoutExercise,
                            canMoveUp: index > 0,
                            canMoveDown: index < viewModel.session.exercises.count - 1,
                            onMoveUp: {
                                viewModel.moveExercise(workoutExercise.id, by: -1)
                            },
                            onMoveDown: {
                                viewModel.moveExercise(workoutExercise.id, by: 1)
                            }
                        )
                    }
                }

                Button {
                    showingExercisePicker = true
                } label: {
                    Label("add exercise", systemImage: "plus")
                        .font(.headline)
                        .fontWeight(.medium)
                        .frame(maxWidth: 220)
                }
                .buttonStyle(.bordered)

                Button("discard workout", role: .destructive) {
                    showingDiscardAlert = true
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView(
                title: "Add Exercise",
                allExercises: allExercises,
                selectedExerciseIDs: [],
                onPick: { exercise in
                    viewModel.addExercise(exercise)
                    showingExercisePicker = false
                }
            )
        }
        .alert("Discard Workout?", isPresented: $showingDiscardAlert) {
            Button("Discard", role: .destructive) {
                viewModel.discardWorkout()
                dismiss()
            }

            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove the current workout session.")
        }
        .onReceive(timer) { newTime in
            if viewModel.session.endedAt == nil {
                now = newTime
            }
        }
    }

    private var durationText: String {
        let interval = (viewModel.session.endedAt ?? now).timeIntervalSince(viewModel.session.startedAt)
        return interval.workoutDurationText
    }
}

private let previewExercise = Exercise(
    id: "Barbell_Bench_Press",
    name: "Barbell Bench Press",
    force: "push",
    level: "beginner",
    mechanic: "compound",
    equipment: "barbell",
    primaryMuscles: ["chest"],
    secondaryMuscles: ["triceps", "shoulders"],
    instructions: [],
    category: "strength",
    images: []
)

private let previewSession = WorkoutSession(
    id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
    routineID: "mock_upper_body",
    name: "Upper Body",
    startedAt: Date().addingTimeInterval(-900),
    endedAt: nil,
    exercises: [
        WorkoutExercise(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444444429")!,
            exerciseID: previewExercise.id,
            exerciseNameSnapshot: previewExercise.name,
            sets: [
                WorkoutSet(weight: 45, reps: 8, isCompleted: true),
                WorkoutSet(weight: 45, reps: 8, isCompleted: false)
            ]
        )
    ]
)

#Preview {
    NavigationStack {
        WorkoutSessionView(
            session: previewSession,
            allExercises: [previewExercise]
        )
    }
}
