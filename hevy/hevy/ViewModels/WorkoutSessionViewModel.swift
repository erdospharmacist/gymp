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

    //creates an editable view model for one workout session
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

    //adds an exercise block to the workout and saves the draft
    func addExercise(_ exercise: Exercise) {
        let workoutExercise = WorkoutExercise(
            exerciseID: exercise.id,
            exerciseNameSnapshot: exercise.name
        )

        draft.exercises.append(workoutExercise)
        saveSession()
    }

    //removes an exercise block from the workout and saves the draft
    func removeExercise(_ workoutExerciseID: UUID) {
        draft.exercises.removeAll { $0.id == workoutExerciseID }
        saveSession()
    }

    // MARK: - Set management

    //adds a new set to a workout exercise, optionally seeded with previous values
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

    //removes a set from a workout exercise and saves the draft
    func removeSet(from workoutExerciseID: UUID, setID: UUID) {
        updateExercise(workoutExerciseID) { workoutExercise in
            workoutExercise.sets.removeAll { $0.id == setID }
            return true
        }
    }

    //toggles whether one set is marked complete
    func toggleSetCompleted(workoutExerciseID: UUID, setID: UUID) {
        updateSet(workoutExerciseID: workoutExerciseID, setID: setID) { set in
            set.isCompleted.toggle()
        }
    }

    //updates both weight and reps for one set
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

    //updates just the weight for one set
    func updateSetWeight(
        workoutExerciseID: UUID,
        setID: UUID,
        weight: Double
    ) {
        updateSet(workoutExerciseID: workoutExerciseID, setID: setID) { set in
            set.weight = weight
        }
    }

    //updates just the reps for one set
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

    //renames the workout session when the new name is not blank
    func renameSession(to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        draft.name = trimmed
        saveSession()
    }

    //marks the workout as finished and saves it with an end time
    func finishWorkout() {
        saveSession(endedAt: Date())
    }

    //deletes the current workout session from storage
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

    //saves the workout as still in progress
    func saveSession() {
        saveSession(endedAt: nil)
    }

    //saves the workout with the provided end time state
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

    //reloads the current workout from storage if it still exists
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

    //applies a change to one workout exercise and saves when it changed
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

    //applies a change to one set inside one workout exercise
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
