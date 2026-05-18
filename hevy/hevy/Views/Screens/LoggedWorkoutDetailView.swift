import SwiftUI
import TrainingCore

struct LoggedWorkoutDetailView: View {
    let session: WorkoutSession

    var body: some View {
        List {
            Section("Workout Info") {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(session.name)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Started")
                    Spacer()
                    Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                        .foregroundColor(.secondary)
                }

                if let endedAt = session.endedAt {
                    HStack {
                        Text("Finished")
                        Spacer()
                        Text(endedAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text("Duration")
                    Spacer()
                    Text(session.duration.workoutDurationText)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Total Volume")
                    Spacer()
                    Text(session.totalVolume.kgText)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Total Sets")
                    Spacer()
                    Text("\(session.totalSets)")
                        .foregroundColor(.secondary)
                }
            }

            ForEach(session.exercises) { workoutExercise in
                Section(workoutExercise.exerciseNameSnapshot) {
                    ForEach(Array(workoutExercise.sets.enumerated()), id: \.element.id) { index, set in
                        HStack {
                            Text("Set \(index + 1)")
                            Spacer()
                            Text("\(set.weight.kgText) × \(set.reps)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(session.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
