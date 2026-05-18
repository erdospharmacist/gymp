import Foundation

public struct WorkoutSet: Identifiable, Codable, Hashable {
    //ctrl-shift for multiclick
    public let id: UUID
    public var weight: Double
    public var reps: Int
    public var isCompleted: Bool
    var previousWeight: Double?
    public var previousReps: Int?

    public init(
        id: UUID = UUID(),
        weight: Double = 0,
        reps: Int = 0,
        isCompleted: Bool = false,
        previousWeight: Double? = nil,
        previousReps: Int? = nil
    ) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
        self.previousWeight = previousWeight
        self.previousReps = previousReps
    }

    public var volume: Double {
        weight * Double(reps)
    }

    public var previousSummary: String? {
        guard let previousWeight, let previousReps else { return nil }
        return "\(previousWeight.kgText) x \(previousReps)"
    }
}

public extension Double {
    var kgText: String {
        if self == floor(self) {
            return "\(Int(self))kg"
        } else {
            return "\(self.formatted(.number.precision(.fractionLength(1))))kg"
        }
    }
}
