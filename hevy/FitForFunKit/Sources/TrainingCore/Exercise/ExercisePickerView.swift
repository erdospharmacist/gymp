import SwiftUI

public struct ExercisePickerView: View {
    private let title: String
    @State private var allExercises: [Exercise]
    private let selectedExerciseIDs: Set<String>
    private let onPick: (Exercise) -> Void

    //dismiss done by this https://developer.apple.com/documentation/swiftui/environmentvalues/dismiss
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""

    //creates an exercise picker that only chooses from the existing exercise catalog
    public init(
        title: String,
        allExercises: [Exercise],
        selectedExerciseIDs: Set<String>,
        onPick: @escaping (Exercise) -> Void
    ) {
        self.title = title
        _allExercises = State(initialValue: allExercises)
        self.selectedExerciseIDs = selectedExerciseIDs
        self.onPick = onPick
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
            }
        }
    }
}
