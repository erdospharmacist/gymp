import Foundation

// Represents one exercise loaded from JSON.
//
// Codable:
// Allows Swift to automatically convert between JSON and this struct.
//
// Identifiable:
// Means each Exercise has a unique `id`, which is useful for SwiftUI lists.
//
// Hashable:
// Allows Exercise to be used in Sets, Dictionaries, or compared efficiently.
public struct Exercise: Identifiable, Codable, Hashable {

    public let id: String

    public let name: String

    public let force: String?

    public let level: String?

    public let mechanic: String?

    public let equipment: String?

    public let primaryMuscles: [String]

    public let secondaryMuscles: [String]

    public let instructions: [String]

    public let category: String?

    public let images: [String]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case force
        case level
        case mechanic
        case equipment
        case primaryMuscles
        case secondaryMuscles
        case instructions
        case category
        case images
    }

    public init(
        id: String,
        name: String,
        force: String? = nil,
        level: String? = nil,
        mechanic: String? = nil,
        equipment: String?,
        primaryMuscles: [String],
        secondaryMuscles: [String],
        instructions: [String] = [],
        category: String? = nil,
        images: [String] = []
    ) {
        self.id = id
        self.name = name
        self.force = force
        self.level = level
        self.mechanic = mechanic
        self.equipment = equipment
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.instructions = instructions
        self.category = category
        self.images = images
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.force = try container.decodeIfPresent(String.self, forKey: .force)
        self.level = try container.decodeIfPresent(String.self, forKey: .level)
        self.mechanic = try container.decodeIfPresent(String.self, forKey: .mechanic)
        self.equipment = try container.decodeIfPresent(String.self, forKey: .equipment)
        self.primaryMuscles = try container.decodeIfPresent([String].self, forKey: .primaryMuscles) ?? []
        self.secondaryMuscles = try container.decodeIfPresent([String].self, forKey: .secondaryMuscles) ?? []
        self.instructions = try container.decodeIfPresent([String].self, forKey: .instructions) ?? []
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.images = try container.decodeIfPresent([String].self, forKey: .images) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(force, forKey: .force)
        try container.encodeIfPresent(level, forKey: .level)
        try container.encodeIfPresent(mechanic, forKey: .mechanic)
        try container.encodeIfPresent(equipment, forKey: .equipment)
        try container.encode(primaryMuscles, forKey: .primaryMuscles)
        try container.encode(secondaryMuscles, forKey: .secondaryMuscles)
        try container.encode(instructions, forKey: .instructions)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encode(images, forKey: .images)
    }
}

public struct ExerciseDraft {
    public var name: String = ""
    public var equipment: String = ""
    public var primaryMusclesText: String = ""
    public var secondaryMusclesText: String = ""

    public init() {}

    //instance method
    public func toExercise() -> Exercise {
        //functionality provided by foundation https://developer.apple.com/documentation/foundation/nsstring/trimmingcharacters(in:)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        return Exercise(
            id: String(UUID().uuidString),
            name: trimmedName,
            //an optional https://www.reddit.com/r/swift/comments/6yi38z/handling_empty_optional_strings_in_swift/
            equipment: equipment.nilIfBlank,
            primaryMuscles: Self.parseCommaSeparated(primaryMusclesText),
            secondaryMuscles: Self.parseCommaSeparated(secondaryMusclesText)
        )
    }

    //getting rid of comma
    //static is cool it means function belongs to the type name when you call it
    private static func parseCommaSeparated(_ text: String) -> [String] {
        text
            .split(separator: ",")
            //map same as in python
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

//extension here just to try it out in case want to use elsewhere
private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
