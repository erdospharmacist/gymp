import Foundation
import TrainingCore

final class ExerciseStore {
    //I think this is probably best practice need to Ask Stu, intuitively though makes more readable
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

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
    func addUserExercise(_ exercise: Exercise) throws {
        var existing = loadUserExercises()

        // Replace same ID if it already exists
        existing.removeAll { $0.id == exercise.id }
        existing.append(exercise)

        try saveUserExercises(existing)
    }

    //private func
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
    private func loadUserExercises() -> [Exercise] {
        let fileURL = userExercisesFileURL()
        //omg no enum of cases of what not to have, just guard in the event of bad cases happening i.e. "guard against"
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("📭 no user_exercises.json found yet")
            return []
        }
        do {
            //read data
            let data = try Data(contentsOf: fileURL)
            let exercises = try decoder.decode([Exercise].self, from: data)
            //this is printed in the corner on Xcode debugger, just copying what I saw Isaacs code do when it threw all those emojis
            print("✅ loaded \(exercises.count) user-created exercises")
            return exercises
        } catch {
            print("❌ failed to load user exercises: \(error)")
            return []
        }
    }
    //
    private func saveUserExercises(_ exercises: [Exercise]) throws {

        let fileURL = userExercisesFileURL()
        let data = try encoder.encode(exercises)
        try data.write(to: fileURL, options: .atomic)
        print("💾 saved \(exercises.count) user-created exercises to \(fileURL.path)")
    }

    private func userExercisesFileURL() -> URL {
        applicationSupportDirectory().appendingPathComponent("user_exercises.json")
    }

    func deleteUserExercise(id: String) throws {
        var existing = loadUserExercises()
        existing.removeAll { $0.id == id }
        try saveUserExercises(existing)
    }

    //Creates the direc if doesn't exist else just pulls it up
    private func applicationSupportDirectory() -> URL {
        //had to use AI for this, still a bit unsure on this and what correct way to do is
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        //make sure directory exists before trying to save into it and just tries to create it
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                print("❌ Failed to create Application Support directory: \(error)")
            }
        }
        //return the path
        return url
    }
}
