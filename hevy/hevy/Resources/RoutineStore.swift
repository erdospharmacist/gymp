import Foundation
import TrainingCore
import TrainingStorage

//
final class RoutineStore {
    private let store: JSONFileStore<[Routine]>

    //sets up the JSON store that persists user routines
    init() {
        do {
            store = try JSONFileStore(filename: "user_routines.json")
        } catch {
            fatalError("Failed to initialise routine storage: \(error)")
        }
    }

    //loads all saved routines, returning an empty list if loading fails
    func loadRoutines() -> [Routine] {
        do {
            return try store.load(default: [])
        } catch {
            print("Failed to load routines: \(error)")
            return []
        }
    }

    //writing try inside a func means that you get this weird logic meaning
    //it has to be handled outside the function and that is indicated by the throws
    //saves the full routine list to disk
    func saveRoutines(_ routines: [Routine]) throws {
        try store.save(routines)
    }
}
