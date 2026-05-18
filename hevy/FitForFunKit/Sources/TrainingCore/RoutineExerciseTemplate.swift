import Foundation

public struct RoutineExerciseTemplate: Identifiable, Codable, Hashable {
    public var id: String { exerciseID }
    public var exerciseID: String
    public var targetSets: Int
    public var targetReps: Int?
    public var notes: String

    public init(
        exerciseID: String,
        targetSets: Int = 0,
        targetReps: Int? = nil,
        notes: String = ""
    ) {
        self.exerciseID = exerciseID
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.notes = notes
    }
}
