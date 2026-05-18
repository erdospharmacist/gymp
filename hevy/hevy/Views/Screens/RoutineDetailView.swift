import SwiftUI
import TrainingCore

struct RoutineDetailView: View {
    let routineID: String
    @ObservedObject var routineViewModel: RoutineListViewModel
    let allExercises: [Exercise]

    @State private var showingExercisePicker = false
    @State private var editedName = ""

    private var routine: Routine? {
        routineViewModel.routine(withID: routineID)
    }

    private var routineExercises: [Exercise] {
        guard let routine else { return [] }
        return routine.exercises(from: allExercises)
    }

    var body: some View {
        Group {
            if let routine {
                List {
                    Section {
                        NavigationLink {
                            WorkoutSessionView(
                                session: WorkoutSession.make(from: routine, allExercises: allExercises),
                                allExercises: allExercises
                            )
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Workout")
                            }
                            .font(.headline)
                        }
                        .disabled(routine.exerciseIDs.isEmpty)
                    }

                    Section("Routine Name") {
                        TextField("Routine name", text: $editedName)

                        Button("Save Name") {
                            routineViewModel.renameRoutine(routine, to: editedName)
                        }
                    }

                    Section("Exercises") {
                        if routineExercises.isEmpty {
                            Text("No exercises in this routine yet")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(routineExercises) { exercise in
                                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                    Text(exercise.name)
                                }
                            }
                            .onDelete { offsets in
                                let idsToRemove = offsets.map { routineExercises[$0].id }
                                for id in idsToRemove {
                                    routineViewModel.removeExercise(id, from: routine)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(routine.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingExercisePicker = true
                        } label: {
                            Text("add exercise")
                        }
                    }
                }
                .sheet(isPresented: $showingExercisePicker) {
                    ExercisePickerView(
                        title: "Edit Exercises",
                        allExercises: allExercises,
                        selectedExerciseIDs: Set(routine.exerciseIDs),
                        allowsCreation: true,
                        onPick: { exercise in
                            guard let routine = routineViewModel.routine(withID: routineID) else { return }
                            if routine.exerciseIDs.contains(exercise.id) {
                                routineViewModel.removeExercise(exercise.id, from: routine)
                            } else {
                                routineViewModel.addExercise(exercise, to: routine)
                            }
                        },
                        onCreate: { exercise in
                            guard let routine = routineViewModel.routine(withID: routineID) else { return }
                            routineViewModel.addExercise(exercise, to: routine)
                        }
                    )
                }
                .onAppear {
                    editedName = routine.name
                }
            } else {
                Text("Routine not found")
                    .foregroundColor(.secondary)
            }
        }
    }
}
