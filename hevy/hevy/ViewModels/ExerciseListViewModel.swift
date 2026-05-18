// Foundation has the JSON stuff for reading etc
import Foundation
import Combine
import TrainingCore

//cannot be subclassed
//ObservableObject is a class that holds data and lets swiftui know when data changes so the UI can update
final class ExerciseListViewModel: ObservableObject {
    // reactive rendering, any alteration to the array makes the model re-render
    @Published var exercises: [Exercise] = []
    //has to be reactive for the searchText else screen wouldn't rerender when we type thigns in
    @Published var searchText: String = ""

    private let store = ExerciseStore()
    //
    init() {
        loadExercises()
    }

    var filteredExercises: [Exercise] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if query.isEmpty {
            return exercises
        }
        //search here just looks at exercises in the array once they have been filtered by what is listed below
        return exercises.filter { exercise in
            //testing Foundation package capabilities
            //this provides a boolean value indicating whether the string contains a given string based doesnt care about case
            exercise.name.localizedCaseInsensitiveContains(query) ||
            exercise.primaryMuscles.joined(separator: " ").localizedCaseInsensitiveContains(query) ||
            exercise.secondaryMuscles.joined(separator: " ").localizedCaseInsensitiveContains(query) ||
            (exercise.equipment?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
    //
    func createExercise(from draft: ExerciseDraft) {
        let newExercise = draft.toExercise()
        do {
            try store.addUserExercise(newExercise)
            loadExercises()
        } catch {
            print("didnt save: \(error)")
        }
    }

    func deleteExercise(_ exercise: Exercise) {
        do {
            try store.deleteUserExercise(id: exercise.id)
            loadExercises()
        } catch {
            print("didnt delete: \(error)")
        }
    }

    func loadExercises() {
        exercises = store.loadAllExercises()
    }
}
