import Foundation

import Combine
import TrainingCore

//ObservableObject means that whenever something happens to a published value this will produce a publisher when it is changed
final class RoutineListViewModel: ObservableObject {
    @Published var routines: [Routine] = []
    private let store = RoutineStore()

    //loads routines immediately so routine screens start with current data
    init() {
        loadRoutines()
    }

    //reloads routines from storage and keeps them sorted by name
    func loadRoutines() {
        routines = store.loadRoutines().sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    //creates a new routine after trimming blank text
    func addRoutine(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        routines.append(Routine(name: trimmed))
        saveRoutines()
    }

    //removes a routine from the in-memory list and saves the change
    func deleteRoutine(_ routine: Routine) {
        //$0 is current item in array
        routines.removeAll { $0.id == routine.id }
        saveRoutines()
    }

    //renames an existing routine when the new name is not blank
    func renameRoutine(_ routine: Routine, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        routines[index].name = trimmed
        saveRoutines()
    }

    //links an exercise to a routine if it is not already included
    func addExercise(_ exercise: Exercise, to routine: Routine) {
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        if !routines[index].exerciseTemplates.contains(where: { $0.exerciseID == exercise.id }) {
            routines[index].exerciseTemplates.append(RoutineExerciseTemplate(exerciseID: exercise.id))
            saveRoutines()
        }
    }

    //removes an exercise link from a routine without deleting the exercise itself
    func removeExercise(_ exerciseID: String, from routine: Routine) {
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        routines[index].exerciseTemplates.removeAll { $0.exerciseID == exerciseID }
        saveRoutines()
    }

    //finds a routine currently loaded in memory
    func routine(withID id: String) -> Routine? {
        routines.first { $0.id == id }
    }

    //persists the current routine list and reloads it after saving
    private func saveRoutines() {
        do {
            //store function
            try store.saveRoutines(routines)
            loadRoutines()
        } catch {
            print("Failed to save routines: \(error)")
        }
    }
}
