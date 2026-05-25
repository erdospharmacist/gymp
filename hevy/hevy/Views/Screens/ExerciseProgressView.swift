import SwiftUI
import TrainingCore

struct ExerciseProgressView: View {
    @State private var exercises: [Exercise] = []
    @State private var sessions: [WorkoutSession] = []
    @State private var selectedExerciseID: String?
    @State private var errorMessage: String?

    //only finished workouts should count toward stats
    private var loggedSessions: [WorkoutSession] {
        sessions.filter { $0.endedAt != nil }
    }

    private var exerciseChoices: [ExerciseProgressChoice] {
        let currentExerciseChoices = exercises.map {
            ExerciseProgressChoice(id: $0.id, name: $0.name, isDeleted: false)
        }

        //pull deleted exercises back out of old workouts so history does not disappear
        let knownExerciseIDs = Set(exercises.map(\.id))
        let deletedExerciseChoices = Dictionary(
            grouping: loggedSessions
                .flatMap(\.exercises)
                .filter { !knownExerciseIDs.contains($0.exerciseID) },
            by: \.exerciseID
        )
        .map { exerciseID, workoutExercises in
            ExerciseProgressChoice(
                id: exerciseID,
                name: "\(workoutExercises.first?.exerciseNameSnapshot ?? exerciseID) (deleted)",
                isDeleted: true
            )
        }

        return (currentExerciseChoices + deletedExerciseChoices).sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    private var selectedChoice: ExerciseProgressChoice? {
        exerciseChoices.first { $0.id == selectedExerciseID }
    }

    private var selectedEntries: [ExerciseProgressEntry] {
        guard let selectedExerciseID else { return [] }

        //each workout can contain the same exercise more than once so add all matching blocks together
        return loggedSessions
            .compactMap { session in
                let matchingExercises = session.exercises.filter {
                    $0.exerciseID == selectedExerciseID
                }

                guard !matchingExercises.isEmpty else { return nil }

                return ExerciseProgressEntry(
                    session: session,
                    weightMoved: matchingExercises.reduce(0) { $0 + $1.totalVolume },
                    totalSets: matchingExercises.reduce(0) { $0 + $1.totalSets }
                )
            }
            .sorted { $0.session.startedAt > $1.session.startedAt }
    }

    private var chronologicalEntries: [ExerciseProgressEntry] {
        selectedEntries.sorted { $0.session.startedAt < $1.session.startedAt }
    }

    private var totalWeightMoved: Double {
        selectedEntries.reduce(0) { $0 + $1.weightMoved }
    }

    private var averageWeightMoved: Double {
        guard !selectedEntries.isEmpty else { return 0 }
        return totalWeightMoved / Double(selectedEntries.count)
    }

    private var bestEntry: ExerciseProgressEntry? {
        selectedEntries.max { $0.weightMoved < $1.weightMoved }
    }

    var body: some View {
        List {
            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }

            if exerciseChoices.isEmpty {
                Section {
                    VStack(spacing: 10) {
                        Text("No exercise progression yet")
                            .font(.headline)

                        Text("Finish workouts with exercises to see total weight moved here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 36)
                }
            } else {
                Section("Exercise") {
                    Picker("Exercise", selection: selectedExerciseBinding) {
                        ForEach(exerciseChoices) { choice in
                            Text(choice.name)
                                .tag(Optional(choice.id))
                        }
                    }
                }

                if let selectedChoice {
                    Section {
                        VStack(alignment: .leading, spacing: 18) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(selectedChoice.name)
                                    .font(.title2)
                                    .fontWeight(.semibold)

                                if selectedChoice.isDeleted {
                                    Text("This exercise was deleted, but its logged workout data is still counted.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            HStack {
                                statItem(title: "Total Weight", value: totalWeightMoved.kgText)
                                Divider()
                                statItem(title: "Workouts", value: "\(selectedEntries.count)")
                                Divider()
                                statItem(title: "Average", value: averageWeightMoved.kgText)
                            }
                            .frame(minHeight: 54)
                        }
                        .padding(.vertical, 6)
                    }

                    if !chronologicalEntries.isEmpty {
                        Section("Progression") {
                            ExerciseProgressChart(
                                entries: chronologicalEntries,
                                maxWeight: bestEntry?.weightMoved ?? 0
                            )
                        }
                    }

                    if let bestEntry {
                        Section("Best Workout") {
                            NavigationLink(destination: LoggedWorkoutDetailView(session: bestEntry.session)) {
                                ExerciseProgressRow(entry: bestEntry)
                            }
                        }
                    }

                    Section("Workout History") {
                        if selectedEntries.isEmpty {
                            Text("No workouts logged for this exercise yet")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(selectedEntries) { entry in
                                NavigationLink(destination: LoggedWorkoutDetailView(session: entry.session)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ExerciseProgressRow(entry: entry)

                                        ProgressView(
                                            value: progressValue(for: entry),
                                            total: 1
                                        )
                                        .tint(.green)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Exercise Progress")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                loadData()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .onAppear {
            loadData()
        }
    }

    private var selectedExerciseBinding: Binding<String?> {
        Binding(
            get: {
                selectedExerciseID
            },
            set: { newValue in
                selectedExerciseID = newValue
            }
        )
    }

    //reloads exercises and logged sessions used by this progress screen
    private func loadData() {
        //load current definitions and logged workout data separately then join by exerciseID
        exercises = ExerciseStore().loadAllExercises()

        do {
            sessions = try WorkoutSessionStore().loadSessions()
            errorMessage = nil
        } catch {
            sessions = []
            errorMessage = "Failed to load workout sessions: \(error)"
        }

        let choiceIDs = Set(exerciseChoices.map(\.id))
        //if the selected exercise was deleted from the picker list choose the first available one
        if selectedExerciseID == nil || selectedExerciseID.map({ !choiceIDs.contains($0) }) == true {
            selectedExerciseID = exerciseChoices.first?.id
        }
    }

    //builds one compact summary value for the selected exercise
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }

    //scales one workout's total volume against the best workout for this exercise
    private func progressValue(for entry: ExerciseProgressEntry) -> Double {
        //turn the best workout into 100% so the other rows can scale against it
        guard let bestEntry, bestEntry.weightMoved > 0 else { return 0 }
        return entry.weightMoved / bestEntry.weightMoved
    }
}

#Preview {
    NavigationStack {
        ExerciseProgressView()
    }
}
