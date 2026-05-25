import Foundation
import TrainingCore
import TrainingStorage

final class ExerciseStore {
    //I think this is probably best practice need to Ask Stu, intuitively though makes more readable
    private let decoder = JSONDecoder()
    private let store: JSONFileStore<[Exercise]>

    //sets up the JSON store for user-created exercises
    init() {
        do {
            store = try JSONFileStore(filename: "user_exercises.json")
        } catch {
            fatalError("Failed to initialise exercise storage: \(error)")
        }
    }

    //loads bundled and user-created exercises into one sorted catalog
    func loadAllExercises() -> [Exercise] {
        let bundledExercises = loadBundledExercises()
        let userExercises = loadUserExercises()

        // merge by ID so everything appears in one list
        // if a user-created exercise has the same ID as a bundled one, the user-created one wins

        var mergedByID: [String: Exercise] = [:]

        //creating the dictionary by looping through bundled ones
        for exercise in bundledExercises {
            mergedByID[exercise.id] = exercise
        }
        //another loop to overwrite the previous ones with our user created ones
        for exercise in userExercises {
            mergedByID[exercise.id] = exercise
        }
        //sorting it
        return mergedByID.values.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    //This my func for adding a user exercise
    //adds or replaces one user-created exercise in saved storage
    func addUserExercise(_ exercise: Exercise) throws {
        var existing = loadUserExercises()

        // Replace same ID if it already exists
        existing.removeAll { $0.id == exercise.id }
        existing.append(exercise)

        try saveUserExercises(existing)
    }

    //private func
    //loads the exercise JSON files that are bundled with the app
    private func loadBundledExercises() -> [Exercise] {

        let filesInExerciseFolder = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "exercises") ?? []
        let filesInRoot = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []

        let allFiles = Array(Set(filesInExerciseFolder + filesInRoot)).sorted {
            $0.lastPathComponent < $1.lastPathComponent
        }

        var loadedByID: [String: Exercise] = [:]

        for fileURL in allFiles {
            do {
                let data = try Data(contentsOf: fileURL)
                let exercise = try decoder.decode(Exercise.self, from: data)
                loadedByID[exercise.id] = exercise
                print("loaded: \(exercise.name)")

            } catch {
                print("failed decoding \(fileURL.lastPathComponent): \(error)")
            }
        }
        print("final loaded ex count: \(loadedByID.count)")

        return loadedByID.values.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    //load saved exercises from the disk
    //I think should note this expect ONE file containing [Exercise]
    //loads user-created exercises from Application Support
    private func loadUserExercises() -> [Exercise] {
        do {
            let exercises = try store.load(default: [])
            //this is printed in the corner on Xcode debugger, just copying what I saw Isaacs code do when it threw all those emojis
            print("✅ loaded \(exercises.count) user-created exercises")
            return exercises
        } catch {
            print("❌ failed to load user exercises: \(error)")
            return []
        }
    }
    //
    //saves all user-created exercises back to disk
    private func saveUserExercises(_ exercises: [Exercise]) throws {
        try store.save(exercises)
        print("💾 saved \(exercises.count) user-created exercises")
    }

    //deletes a user-created exercise by ID from saved storage
    func deleteUserExercise(id: String) throws {
        var existing = loadUserExercises()
        existing.removeAll { $0.id == id }
        try saveUserExercises(existing)
    }
}
