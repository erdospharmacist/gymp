import Foundation
import TrainingCore
import TrainingStorage

final class WorkoutSessionStore {
    private let store: JSONFileStore<[WorkoutSession]>

    //sets up the JSON store that persists workout sessions
    init() throws {
        store = try JSONFileStore(filename: "workout_sessions.json")
    }

    //loads every saved workout session from disk
    func loadSessions() throws -> [WorkoutSession] {
        try store.load(default: [])
    }

    //replaces the saved workout session list with the provided list
    func saveSessions(_ sessions: [WorkoutSession]) throws {
        try store.save(sessions)
    }

    //inserts or replaces one workout session before saving the list
    func saveSession(_ session: WorkoutSession) throws {
        var sessions = try loadSessions()

        sessions.removeAll { $0.id == session.id }
        sessions.append(session)

        try saveSessions(sessions)
    }

    //removes one workout session by ID and saves the remaining sessions
    func deleteSession(id: UUID) throws {
        var sessions = try loadSessions()

        sessions.removeAll { $0.id == id }

        try saveSessions(sessions)
    }

    //finds one saved workout session by ID
    func session(withID id: UUID) throws -> WorkoutSession? {
        let sessions = try loadSessions()
        return sessions.first { $0.id == id }
    }
}
