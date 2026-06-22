import Foundation

public struct WorkoutExercise: Identifiable, Codable, Hashable {

    public let id: UUID
    public var exerciseID: String
    public var exerciseNameSnapshot: String
    public var sets: [WorkoutSet]

    //exercise is kept here for old saved workout JSON from before workouts stored exerciseID
    private enum CodingKeys: String, CodingKey {
        case id
        case exerciseID
        case exerciseNameSnapshot
        case exercise
        case sets
    }

    //creates a workout exercise from a stored exercise ID and name snapshot
    public init(
        id: UUID = UUID(),
        exerciseID: String,
        exerciseNameSnapshot: String,
        sets: [WorkoutSet] = []
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.exerciseNameSnapshot = exerciseNameSnapshot
        self.sets = sets
    }

    //creates a workout exercise directly from an exercise definition
    public init(
        id: UUID = UUID(),
        exercise: Exercise,
        sets: [WorkoutSet] = []
    ) {
        self.init(
            id: id,
            exerciseID: exercise.id,
            exerciseNameSnapshot: exercise.name,
            sets: sets
        )
    }

    //reads workout exercise JSON while supporting both current and older save formats
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.sets = try container.decodeIfPresent([WorkoutSet].self, forKey: .sets) ?? []

        if let exerciseID = try container.decodeIfPresent(String.self, forKey: .exerciseID) {
            self.exerciseID = exerciseID
            self.exerciseNameSnapshot = try container.decodeIfPresent(String.self, forKey: .exerciseNameSnapshot) ?? exerciseID
            return
        }

        //old workouts saved a whole Exercise object; convert it into the new linked format when reading
        let exercise = try container.decode(Exercise.self, forKey: .exercise)
        self.exerciseID = exercise.id
        self.exerciseNameSnapshot = exercise.name
    }

    //writes only the workout-specific exercise link data to saved JSON
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        //new saves only store the link and the name snapshot, not the whole exercise definition
        try container.encode(id, forKey: .id)
        try container.encode(exerciseID, forKey: .exerciseID)
        try container.encode(exerciseNameSnapshot, forKey: .exerciseNameSnapshot)
        try container.encode(sets, forKey: .sets)
    }

    public var totalSets: Int {
        completedSets
    }

    public var completedSets: Int {
        //just filters before count
        sets.filter(\.isCompleted).count
    }

    //reduce adds everything together
    //the closure specifies it is adding over the running total
    public var totalVolume: Double {
        //only completed green-ticked sets count toward workout volume and stats
        sets.filter(\.isCompleted).reduce(0.0) { $0 + $1.volume }
    }
}
