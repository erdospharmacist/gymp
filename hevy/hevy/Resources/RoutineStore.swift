import Foundation
import TrainingCore
import TrainingStorage

//
final class RoutineStore {
    private let store: JSONFileStore<[Routine]>

    init() {
        do {
            store = try JSONFileStore(filename: "user_routines.json")
        } catch {
            fatalError("Failed to initialise routine storage: \(error)")
        }
    }

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
    func saveRoutines(_ routines: [Routine]) throws {
        try store.save(routines)
    }
}
