import SwiftUI
import TrainingCore

struct WorkoutSetRowView: View {
    let setNumber: Int
    let set: WorkoutSet

    @Binding var weight: Double
    @Binding var reps: Int

    let onToggleComplete: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text("\(setNumber)")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(width: 40, alignment: .leading)

            Text(set.previousSummary ?? "-")
                .font(.title3)
                .foregroundColor(set.isCompleted ? .primary : .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField("0", value: $weight, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .frame(width: 70)
                .textFieldStyle(.roundedBorder)
                .foregroundColor(set.isCompleted ? .primary : .secondary)

            TextField("0", value: $reps, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: 70)
                .textFieldStyle(.roundedBorder)
                .foregroundColor(set.isCompleted ? .primary : .secondary)

            Button {
                onToggleComplete()
            } label: {
                Image(systemName: set.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.title)
                    .foregroundColor(set.isCompleted ? .green : .primary)
                    .frame(width: 44)
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete Set", systemImage: "trash")
                }
            }
        }
    }
}

private let exampleSet = WorkoutSet(
    id: UUID(),
    weight: 0,
    reps: 0,
    isCompleted: false,
    previousWeight: nil,
    previousReps: nil
)

#Preview {
    NavigationStack {
        WorkoutSetRowView(
            setNumber: 1,
            set: exampleSet,
            weight: .constant(exampleSet.weight),
            reps: .constant(exampleSet.reps),
            onToggleComplete: {},
            onDelete: {}
        )
    }
}
