import Foundation

public struct WorkoutDraft: Identifiable, Hashable {
    public var id: UUID
    public var routineID: String?
    public var name: String
    public var startedAt: Date
    public var exercises: [WorkoutExercise]

    //creates a mutable workout draft used while a workout is still being edited
    public init(
        id: UUID = UUID(),
        routineID: String? = nil,
        name: String,
        startedAt: Date = Date(),
        exercises: [WorkoutExercise] = []
    ) {
        self.id = id
        self.routineID = routineID
        self.name = name
        self.startedAt = startedAt
        self.exercises = exercises
    }

    //rebuilds an editable draft from a saved workout session
    public init(session: WorkoutSession) {
        self.id = session.id
        self.routineID = session.routineID
        self.name = session.name
        self.startedAt = session.startedAt
        self.exercises = session.exercises
    }

    //turns the draft into a session that can be saved, optionally marking it finished
    public func loggedSession(endedAt: Date? = Date()) -> WorkoutSession {
        WorkoutSession(
            id: id,
            routineID: routineID,
            name: name,
            startedAt: startedAt,
            endedAt: endedAt,
            exercises: exercises
        )
    }
}
