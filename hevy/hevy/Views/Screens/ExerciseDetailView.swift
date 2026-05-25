import SwiftUI
import TrainingCore

struct ExerciseDetailView: View {
    let exercise: Exercise

    private var primaryMusclesText: String {
        //ternary if else
        exercise.primaryMuscles.isEmpty ? "None" : exercise.primaryMuscles.joined(separator: ", ")
    }

    private var secondaryMusclesText: String {
        exercise.secondaryMuscles.isEmpty ? "None" : exercise.secondaryMuscles.joined(separator: ", ")
    }

    var body: some View {
        Form {
            Section("Basic Info") {
                LabeledContent("Name", value: exercise.name)
                    .foregroundStyle(.white)
                LabeledContent("Equipment", value: exercise.equipment ?? "None")
                    .foregroundStyle(.white)
                LabeledContent("Mechanic", value: exercise.mechanic ?? "None")
                    .foregroundStyle(.white)
            }
            .listRowBackground(Color.black)

            Section("Muscles") {
                LabeledContent("Primary", value: primaryMusclesText)
                    .foregroundStyle(.white)
                LabeledContent("Secondary", value: secondaryMusclesText)
                    .foregroundStyle(.white)
            }
            .listRowBackground(Color.black)
        }
        .background(Color.white)

        .scrollContentBackground(.hidden)
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    //builds a labeled detail block for exercise metadata
    private func detailSection(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
                .cornerRadius(8)
        }
    }
}

private let exampleExercise = Exercise(
    id: "Barbell_Bench_Press",
    name: "Barbell Bench Press",
    force: "push",
    level: "beginner",
    mechanic: "compound",
    equipment: "barbell",
    primaryMuscles: ["chest"],
    secondaryMuscles: ["triceps", "shoulders"],
    instructions: [],
    category: "strength",
    images: []
)

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: exampleExercise)
    }
}
