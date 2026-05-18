import Foundation
import TrainingCore
import TrainingStorage

final class WorkoutSessionStore {
    private let store: JSONFileStore<[WorkoutSession]>

    init() throws {
        store = try JSONFileStore(filename: "workout_sessions.json")
    }

    func loadSessions() throws -> [WorkoutSession] {
        try store.load(default: [])
    }

    func saveSessions(_ sessions: [WorkoutSession]) throws {
        try store.save(sessions)
    }

    func saveSession(_ session: WorkoutSession) throws {
        var sessions = try loadSessions()

        sessions.removeAll { $0.id == session.id }
        sessions.append(session)

        try saveSessions(sessions)
    }

    func deleteSession(id: UUID) throws {
        var sessions = try loadSessions()

        sessions.removeAll { $0.id == id }

        try saveSessions(sessions)
    }

    func session(withID id: UUID) throws -> WorkoutSession? {
        let sessions = try loadSessions()
        return sessions.first { $0.id == id }
    }
}
