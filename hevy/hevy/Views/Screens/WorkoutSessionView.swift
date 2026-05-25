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
            LazyVStack(spacing: 20) {
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
                    ForEach(viewModel.session.exercises) { workoutExercise in
                        WorkoutExerciseSectionView(
                            viewModel: viewModel,
                            workoutExercise: workoutExercise
                        )
                    }
                }

                Button {
                    showingExercisePicker = true
                } label: {
                    Text("add exercise")
                        .font(.title3)
                        .fontWeight(.medium)
                        .frame(maxWidth: 220)
                }
                .buttonStyle(.borderedProminent)

                HStack(spacing: 16) {
                    Button("settings") {
                        // placeholder
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)

                    Button("discard workout", role: .destructive) {
                        showingDiscardAlert = true
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .background(Color(.systemGray6))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView(
                title: "Add Exercise",
                allExercises: allExercises,
                selectedExerciseIDs: [],
                allowsCreation: false,
                onPick: { exercise in
                    viewModel.addExercise(exercise)
                    showingExercisePicker = false
                },
                onCreate: { _ in }
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

#Preview {
    NavigationStack {
        WorkoutSessionView(
            session: MockTrainingData.activeWorkout,
            allExercises: MockTrainingData.exercises
        )
    }
}
