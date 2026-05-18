import Foundation
import Combine
import TrainingCore

//run on main thread
@MainActor
final class WorkoutSessionViewModel: ObservableObject {
    //current session
    @Published private var draft: WorkoutDraft

    @Published var errorMessage: String?
    //
    private let store: WorkoutSessionStore?

    init(session: WorkoutSession) {
        self.draft = WorkoutDraft(session: session)

        do {
            self.store = try WorkoutSessionStore()
        } catch {
            self.store = nil
            self.errorMessage = "Failed to initialise workout storage: \(error)"
        }
    }

    var session: WorkoutSession {
        get {
            draft.loggedSession(endedAt: nil)
        }
        set {
            draft = WorkoutDraft(session: newValue)
        }
    }

    // MARK: - Exercise management

    func addExercise(_ exercise: Exercise) {
        let workoutExercise = WorkoutExercise(
            exerciseID: exercise.id,
            exerciseNameSnapshot: exercise.name
        )

        draft.exercises.append(workoutExercise)
        saveSession()
    }

    func removeExercise(_ workoutExerciseID: UUID) {
        draft.exercises.removeAll { $0.id == workoutExerciseID }
        saveSession()
    }

    // MARK: - Set management

    func addSet(
        to workoutExerciseID: UUID,
        weight: Double = 0,
        reps: Int = 0,
        previousWeight: Double? = nil,
        previousReps: Int? = nil
    ) {
        let newSet = WorkoutSet(
            weight: weight,
            reps: reps,
            isCompleted: false,
            previousWeight: previousWeight,
            previousReps: previousReps
        )

        updateExercise(workoutExerciseID) { workoutExercise in
            workoutExercise.sets.append(newSet)
            return true
        }
    }

    func removeSet(from workoutExerciseID: UUID, setID: UUID) {
        updateExercise(workoutExerciseID) { workoutExercise in
            workoutExercise.sets.removeAll { $0.id == setID }
            return true
        }
    }

    func toggleSetCompleted(workoutExerciseID: UUID, setID: UUID) {
        updateSet(workoutExerciseID: workoutExerciseID, setID: setID) { set in
            set.isCompleted.toggle()
        }
    }

    func updateSet(
        workoutExerciseID: UUID,
        setID: UUID,
        weight: Double,
        reps: Int
    ) {
        updateSet(workoutExerciseID: workoutExerciseID, setID: setID) { set in
            set.weight = weight
            set.reps = reps
        }
    }

    func updateSetWeight(
        workoutExerciseID: UUID,
        setID: UUID,
        weight: Double
    ) {
        updateSet(workoutExerciseID: workoutExerciseID, setID: setID) { set in
            set.weight = weight
        }
    }

    func updateSetReps(
        workoutExerciseID: UUID,
        setID: UUID,
        reps: Int
    ) {
        updateSet(workoutExerciseID: workoutExerciseID, setID: setID) { set in
            set.reps = reps
        }
    }

    // MARK: - Session lifecycle

    func renameSession(to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        draft.name = trimmed
        saveSession()
    }

    func finishWorkout() {
        saveSession(endedAt: Date())
    }

    func discardWorkout() {
        guard let store else {
            errorMessage = "Workout storage is unavailable."
            return
        }

        do {
            try store.deleteSession(id: session.id)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to discard workout session: \(error)"
        }
    }

    // MARK: - Persistence

    func saveSession() {
        saveSession(endedAt: nil)
    }

    private func saveSession(endedAt: Date?) {
        guard let store else {
            errorMessage = "Workout storage is unavailable."
            return
        }

        do {
            try store.saveSession(draft.loggedSession(endedAt: endedAt))
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save workout session: \(error)"
        }
    }

    func reloadSession() {
        guard let store else {
            errorMessage = "Workout storage is unavailable."
            return
        }

        do {
            guard let reloaded = try store.session(withID: session.id) else {
                return
            }

            draft = WorkoutDraft(session: reloaded)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to reload workout session: \(error)"
        }
    }

    private func updateExercise(
        _ workoutExerciseID: UUID,
        _ update: (inout WorkoutExercise) -> Bool
    ) {
        guard let exerciseIndex = draft.exercises.firstIndex(where: { $0.id == workoutExerciseID }) else {
            return
        }

        if update(&draft.exercises[exerciseIndex]) {
            saveSession()
        }
    }

    private func updateSet(
        workoutExerciseID: UUID,
        setID: UUID,
        _ update: (inout WorkoutSet) -> Void
    ) {
        updateExercise(workoutExerciseID) { workoutExercise in
            guard let setIndex = workoutExercise.sets.firstIndex(where: { $0.id == setID }) else {
                return false
            }

            update(&workoutExercise.sets[setIndex])
            return true
        }
    }
}
