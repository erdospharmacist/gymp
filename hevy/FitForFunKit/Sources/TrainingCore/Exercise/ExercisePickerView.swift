import SwiftUI

public struct ExercisePickerView: View {
    private let title: String
    @State private var allExercises: [Exercise]
    private let selectedExerciseIDs: Set<String>
    private let allowsCreation: Bool
    private let onPick: (Exercise) -> Void
    private let onCreate: (Exercise) -> Void

    //dismiss done by this https://developer.apple.com/documentation/swiftui/environmentvalues/dismiss
    @Environment(\.dismiss) private var dismiss

    @State private var showingCreateExercise = false
    @State private var searchText = ""

    //creates an exercise picker that can optionally create new exercise definitions
    public init(
        title: String,
        allExercises: [Exercise],
        selectedExerciseIDs: Set<String>,
        allowsCreation: Bool,
        onPick: @escaping (Exercise) -> Void,
        onCreate: @escaping (Exercise) -> Void
    ) {
        self.title = title
        _allExercises = State(initialValue: allExercises)
        self.selectedExerciseIDs = selectedExerciseIDs
        self.allowsCreation = allowsCreation
        self.onPick = onPick
        self.onCreate = onCreate
    }

    //filters the current catalog by name for the picker search field
    private var filteredExercises: [Exercise] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return allExercises
        }

        return allExercises.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    //passes only names into the create sheet because that is all duplicate checking needs
    private var existingExerciseNames: [String] {
        allExercises.map(\.name)
    }

    //checks whether the typed exercise name already exists in the current catalog
    private func exerciseNameExists(_ name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return allExercises.contains {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
                .localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }
    }

    public var body: some View {
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
                CreateExerciseView(existingExerciseNames: existingExerciseNames) { draft in
                    let newExercise = draft.toExercise()
                    //keeps the picker from adding a duplicate if the catalog changes while the sheet is open
                    guard !exerciseNameExists(newExercise.name) else { return }
                    allExercises.append(newExercise)
                    onCreate(newExercise)
                }
            }
        }
    }
}
