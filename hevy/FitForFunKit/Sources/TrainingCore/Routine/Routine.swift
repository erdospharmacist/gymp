import Foundation

public struct Routine: Identifiable, Codable, Hashable {
    public let id: String
    public var name: String
    public var exerciseTemplates: [RoutineExerciseTemplate]

    //creates a routine from a simple list of exercise IDs
    public init(id: String = UUID().uuidString, name: String, exerciseIDs: [String] = []) {
        self.id = id
        self.name = name
        self.exerciseTemplates = exerciseIDs.map { RoutineExerciseTemplate(exerciseID: $0) }
    }

    //creates a routine from full exercise templates with set and rep targets
    public init(
        id: String = UUID().uuidString,
        name: String,
        exerciseTemplates: [RoutineExerciseTemplate]
    ) {
        self.id = id
        self.name = name
        self.exerciseTemplates = exerciseTemplates
    }

    public var exerciseIDs: [String] {
        get {
            exerciseTemplates.map(\.exerciseID)
        }
        set {
            exerciseTemplates = newValue.map { RoutineExerciseTemplate(exerciseID: $0) }
        }
    }

    //resolves the routine exercise IDs against the current exercise catalog
    public func exercises(from allExercises: [Exercise]) -> [Exercise] {
        //routines store exercise IDs, then resolve them against the current exercise catalog
        let lookup = Dictionary(uniqueKeysWithValues: allExercises.map { ($0.id, $0) })
        return exerciseIDs.compactMap { lookup[$0] }
    }

    //returns a readable list of exercise names for routine cards and summaries
    public func exerciseSummary(from allExercises: [Exercise]) -> String {
        let exercises = exercises(from: allExercises)

        if exercises.isEmpty {
            return "No exercises yet"
        }

        return exercises
            .map(\.name)
            .joined(separator: ", ")
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case exerciseTemplates
    }

    //reads routines from the current template-based JSON shape
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        exerciseTemplates = try container.decode([RoutineExerciseTemplate].self, forKey: .exerciseTemplates)
    }

    //writes routines using the template-based JSON shape
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(exerciseTemplates, forKey: .exerciseTemplates)
    }
}
