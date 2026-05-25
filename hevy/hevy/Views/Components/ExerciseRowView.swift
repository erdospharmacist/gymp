import SwiftUI
import TrainingCore

struct ExerciseRowView: View {
    let exercise: Exercise
    //
    private var primaryMuscleText: String {
        if exercise.primaryMuscles.isEmpty {
            return "No primary muscle"
        }
        return exercise.primaryMuscles.joined(separator: ", ")
    }

    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                //green color code
                    .fill(Color(.sRGB, red: 0.3, green: 0.7, blue: 0.3))
                    .frame(width: 50, height: 50)
                //default symbol provided by apple
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(primaryMuscleText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            //controlling text need alignment leading else itd be centre of screen
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white)
        .overlay(
            Rectangle()
                .stroke(Color.black, lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

#Preview {
    ExerciseRowView(exercise: MockTrainingData.benchPress)
}
