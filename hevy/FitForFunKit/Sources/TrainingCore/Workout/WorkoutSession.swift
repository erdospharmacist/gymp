import Foundation

public struct WorkoutSession: Identifiable, Codable, Hashable {
    public var id: UUID = UUID()
    public var routineID: String?
    public var name: String
    public var startedAt: Date = Date()
    public var endedAt: Date?
    public var exercises: [WorkoutExercise] = []

    //creates a saved or in-progress workout session
    public init(
        id: UUID = UUID(),
        routineID: String? = nil,
        name: String,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        exercises: [WorkoutExercise] = []
    ) {
        self.id = id
        self.routineID = routineID
        self.name = name
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.exercises = exercises
    }

    public var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }

    public var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }

    public var completedSets: Int {
        exercises.reduce(0) { $0 + $1.completedSets }
    }

    public var duration: TimeInterval {
        (endedAt ?? Date()).timeIntervalSince(startedAt)
    }

    //take in routine convert the exercises in the routine to workout exercises

    //builds a new workout session from a routine template and the current exercise catalog
    public static func make(from routine: Routine, allExercises: [Exercise]) -> WorkoutSession {
        //find matching from the list of exercises puts it into
        let lookup = Dictionary(uniqueKeysWithValues: allExercises.map { ($0.id, $0) })
        let workoutExercises = routine.exerciseTemplates.compactMap { template -> WorkoutExercise? in
            //if an exercise was deleted from the catalog, skip it instead of crashing
            guard let exercise = lookup[template.exerciseID] else { return nil }
            let sets = (0..<template.targetSets).map { _ in
                WorkoutSet(reps: template.targetReps ?? 0)
            }

            //snapshot the name so logged workouts still make sense if the exercise changes later
            return WorkoutExercise(
                exerciseID: exercise.id,
                exerciseNameSnapshot: exercise.name,
                sets: sets
            )
        }

        return WorkoutSession(
            routineID: routine.id,
            name: routine.name,
            exercises: workoutExercises
        )
    }
}
