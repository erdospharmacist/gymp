import SwiftUI
import TrainingCore
import TrainingFeatures

struct ExercisePickerView: View {
    let title: String
    @State var allExercises: [Exercise]
    let selectedExerciseIDs: Set<String>
    let allowsCreation: Bool
    let onPick: (Exercise) -> Void
    let onCreate: (Exercise) -> Void

    //dismiss done by this https://developer.apple.com/documentation/swiftui/environmentvalues/dismiss
    @Environment(\.dismiss) private var dismiss

    @State private var showingCreateExercise = false
    @State private var searchText = ""

    private var filteredExercises: [Exercise] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return allExercises
        }

        return allExercises.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredExercises) { exercise in
                Button {
                    onPick(exercise)
                } label: {
                    HStack {
                        Text(exercise.name)
                            .foregroundColor(.primary)

                        Spacer()
                        if selectedExerciseIDs.contains(exercise.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }

                if allowsCreation {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("New") {
                            showingCreateExercise = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateExercise) {
                CreateExerciseView { draft in
                    let newExercise = draft.toExercise()
                    allExercises.append(newExercise)
                    onCreate(newExercise)
                }
            }
        }
    }
}
