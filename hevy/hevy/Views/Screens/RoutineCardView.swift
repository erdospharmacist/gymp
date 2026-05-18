import SwiftUI
import TrainingCore

struct RoutineCardView: View {
    let routine: Routine
    let allExercises: [Exercise]

    @ObservedObject var routineViewModel: RoutineListViewModel
    let onDelete: () -> Void
    @State private var showingDeleteConfirmation = false

    private var exercisesSummary: String {
        routine.exerciseSummary(from: allExercises)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(routine.name)
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(exercisesSummary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }

                Spacer()

                HStack(spacing: 12) {
                    NavigationLink {
                        RoutineDetailView(
                            routineID: routine.id,
                            routineViewModel: routineViewModel,
                            allExercises: allExercises
                        )
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)

                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
            }

            NavigationLink {
                WorkoutSessionView(
                    session: WorkoutSession.make(from: routine, allExercises: allExercises),
                    allExercises: allExercises
                )
            } label: {
                Text("Start Routine")
                    .mainButtonStyle()
            }
            .buttonStyle(.plain)
            .disabled(routine.exerciseIDs.isEmpty)
            .opacity(routine.exerciseIDs.isEmpty ? 0.5 : 1.0)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        .confirmationDialog(
            "Delete this routine?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: Visibility.visible
        ) {
            Button("Delete Routine", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}
