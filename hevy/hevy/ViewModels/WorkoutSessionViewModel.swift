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
            applyPreviousValuesFromHistory()
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

    //moves one exercise block up or down inside the active workout
    func moveExercise(_ workoutExerciseID: UUID, by offset: Int) {
        guard let currentIndex = draft.exercises.firstIndex(where: { $0.id == workoutExerciseID }) else {
            return
        }

        let newIndex = currentIndex + offset
        guard draft.exercises.indices.contains(newIndex) else {
            return
        }

        draft.exercises.swapAt(currentIndex, newIndex)
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
        let previousSetsByExerciseID = latestPreviousCompletedSetsByExerciseID()

        updateExercise(workoutExerciseID) { workoutExercise in
            let historicalPreviousSet = previousSetsByExerciseID[workoutExercise.exerciseID]?[safe: workoutExercise.sets.count]
            let newSet = WorkoutSet(
                weight: weight,
                reps: reps,
                isCompleted: false,
                previousWeight: previousWeight ?? historicalPreviousSet?.weight,
                previousReps: previousReps ?? historicalPreviousSet?.reps
            )

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
            if !set.isCompleted {
                set.fillCurrentValuesFromPreviousIfEmpty()
            }

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
            applyPreviousValuesFromHistory()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to reload workout session: \(error)"
        }
    }

    //fills each set's previous-value hint from the latest completed workout containing that exercise
    private func applyPreviousValuesFromHistory() {
        let previousSetsByExerciseID = latestPreviousCompletedSetsByExerciseID()
        guard !previousSetsByExerciseID.isEmpty else { return }

        for exerciseIndex in draft.exercises.indices {
            let exerciseID = draft.exercises[exerciseIndex].exerciseID
            guard let previousSets = previousSetsByExerciseID[exerciseID] else { continue }

            for setIndex in draft.exercises[exerciseIndex].sets.indices {
                guard let previousSet = previousSets[safe: setIndex] else { continue }
                draft.exercises[exerciseIndex].sets[setIndex].setPreviousValues(
                    weight: previousSet.weight,
                    reps: previousSet.reps
                )
            }
        }
    }

    //collects the most recent completed set list for each exercise from finished workout history
    private func latestPreviousCompletedSetsByExerciseID() -> [String: [WorkoutSet]] {
        guard let store else { return [:] }

        do {
            let previousSessions = try store.loadSessions()
                .filter { $0.id != draft.id && $0.endedAt != nil && $0.startedAt < draft.startedAt }
                .sorted { $0.startedAt > $1.startedAt }

            var previousSetsByExerciseID: [String: [WorkoutSet]] = [:]
            for session in previousSessions {
                for workoutExercise in session.exercises where previousSetsByExerciseID[workoutExercise.exerciseID] == nil {
                    let completedSets = workoutExercise.sets.filter(\.isCompleted)
                    if !completedSets.isEmpty {
                        previousSetsByExerciseID[workoutExercise.exerciseID] = completedSets
                    }
                }
            }

            return previousSetsByExerciseID
        } catch {
            errorMessage = "Failed to load previous workout values: \(error)"
            return [:]
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

private extension Array {
    //safely reads an array item when optional historical set data may not exist
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
