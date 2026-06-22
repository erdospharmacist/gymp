import Foundation

public struct WorkoutSet: Identifiable, Codable, Hashable {
    //ctrl-shift for multiclick
    public let id: UUID
    public var weight: Double
    public var reps: Int
    public var isCompleted: Bool
    var previousWeight: Double?
    public var previousReps: Int?

    //creates one set, including optional previous values for workout context
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

    //updates the grey previous-value hint shown beside a set
    public mutating func setPreviousValues(weight: Double?, reps: Int?) {
        previousWeight = weight
        previousReps = reps
    }

    //copies previous values into blank current fields when a set is marked complete
    public mutating func fillCurrentValuesFromPreviousIfEmpty() {
        if weight == 0, let previousWeight {
            weight = previousWeight
        }

        if reps == 0, let previousReps {
            reps = previousReps
        }
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
