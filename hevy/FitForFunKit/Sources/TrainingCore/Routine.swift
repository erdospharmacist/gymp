import Foundation

public struct Routine: Identifiable, Codable, Hashable {
    public let id: String
    public var name: String
    public var exerciseTemplates: [RoutineExerciseTemplate]

    public init(id: String = UUID().uuidString, name: String, exerciseIDs: [String] = []) {
        self.id = id
        self.name = name
        self.exerciseTemplates = exerciseIDs.map { RoutineExerciseTemplate(exerciseID: $0) }
    }

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

    public func exercises(from allExercises: [Exercise]) -> [Exercise] {
        let lookup = Dictionary(uniqueKeysWithValues: allExercises.map { ($0.id, $0) })
        return exerciseIDs.compactMap { lookup[$0] }
    }

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
        case exerciseIDs
        case exerciseTemplates
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)

        if let templates = try container.decodeIfPresent([RoutineExerciseTemplate].self, forKey: .exerciseTemplates) {
            exerciseTemplates = templates
        } else {
            let ids = try container.decodeIfPresent([String].self, forKey: .exerciseIDs) ?? []
            exerciseTemplates = ids.map { RoutineExerciseTemplate(exerciseID: $0) }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(exerciseTemplates, forKey: .exerciseTemplates)
    }
}
