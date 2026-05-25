import SwiftUI
import TrainingCore

struct ExerciseProgressRow: View {
    let entry: ExerciseProgressEntry

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.session.startedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.headline)

                Text("\(entry.totalSets) sets • \(entry.session.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(entry.weightMoved.kgText)
                .font(.headline)
                .foregroundColor(.green)
        }
    }
}
