import Foundation

import Combine
import TrainingCore

//ObservableObject means that whenever something happens to a published value this will produce a publisher when it is changed
final class RoutineListViewModel: ObservableObject {
    @Published var routines: [Routine] = []
    private let store = RoutineStore()

    init() {
        loadRoutines()
    }

    func loadRoutines() {
        routines = store.loadRoutines().sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    func addRoutine(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        routines.append(Routine(name: trimmed))
        saveRoutines()
    }

    func deleteRoutine(_ routine: Routine) {
        //$0 is current item in array
        routines.removeAll { $0.id == routine.id }
        saveRoutines()
    }

    func renameRoutine(_ routine: Routine, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        routines[index].name = trimmed
        saveRoutines()
    }

    func addExercise(_ exercise: Exercise, to routine: Routine) {
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        if !routines[index].exerciseIDs.contains(exercise.id) {
            routines[index].exerciseIDs.append(exercise.id)
            saveRoutines()
        }
    }

    func removeExercise(_ exerciseID: String, from routine: Routine) {
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        routines[index].exerciseIDs.removeAll { $0 == exerciseID }
        saveRoutines()
    }

    func routine(withID id: String) -> Routine? {
        routines.first { $0.id == id }
    }

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
