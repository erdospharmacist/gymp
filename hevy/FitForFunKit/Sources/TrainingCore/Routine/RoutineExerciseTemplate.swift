import Foundation

public struct RoutineExerciseTemplate: Identifiable, Codable, Hashable {
    public var id: String { exerciseID }
    //this points to Exercise.id rather than storing the whole exercise in the routine
    public var exerciseID: String
    public var targetSets: Int
    public var targetReps: Int?
    public var notes: String

    //creates one exercise entry inside a routine template
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

    //summarises the planned work for routine exercise rows
    public var trainingSummary: String {
        let setWord = targetSets == 1 ? "set" : "sets"

        guard let targetReps else {
            return "\(targetSets) \(setWord)"
        }

        let repWord = targetReps == 1 ? "rep" : "reps"
        return "\(targetSets) \(setWord) x \(targetReps) \(repWord)"
    }
}
