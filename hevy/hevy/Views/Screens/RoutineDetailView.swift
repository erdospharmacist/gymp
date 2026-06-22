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
                        .disabled(routine.exerciseTemplates.isEmpty)
                    }

                    Section("Routine Name") {
                        TextField("Routine name", text: $editedName)

                        Button("Save Name") {
                            routineViewModel.renameRoutine(routine, to: editedName)
                        }
                    }

                    Section("Exercises") {
                        if routine.exerciseTemplates.isEmpty {
                            Text("No exercises in this routine yet")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(routine.exerciseTemplates) { template in
                                if let exercise = exercise(for: template) {
                                    NavigationLink {
                                        RoutineExerciseDetailFormView(
                                            exercise: exercise,
                                            template: template,
                                            onDone: { updatedTemplate in
                                                guard let routine = routineViewModel.routine(withID: routineID) else { return }
                                                routineViewModel.saveExerciseTemplate(updatedTemplate, to: routine)
                                            }
                                        )
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(exercise.name)

                                            Text(template.trainingSummary)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)

                                            if !template.notes.isEmpty {
                                                Text(template.notes)
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(2)
                                            }
                                        }
                                    }
                                } else {
                                    Text("Missing exercise: \(template.exerciseID)")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .onDelete { offsets in
                                let idsToRemove = offsets.map { routine.exerciseTemplates[$0].exerciseID }
                                for id in idsToRemove {
                                    routineViewModel.removeExercise(id, from: routine)
                                }
                            }
                            .onMove { source, destination in
                                routineViewModel.moveExerciseTemplates(in: routine, from: source, to: destination)
                            }
                        }
                    }
                }
                .navigationTitle(routine.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingExercisePicker = true
                        } label: {
                            Text("add exercise")
                        }
                    }
                }
                .sheet(isPresented: $showingExercisePicker) {
                    RoutineExercisePickerView(
                        allExercises: allExercises,
                        existingTemplates: routine.exerciseTemplates,
                        onSave: { template in
                            guard let routine = routineViewModel.routine(withID: routineID) else { return }
                            routineViewModel.saveExerciseTemplate(template, to: routine)
                        },
                        onFinish: {
                            showingExercisePicker = false
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

    //resolves one routine exercise template against the current exercise catalog
    private func exercise(for template: RoutineExerciseTemplate) -> Exercise? {
        allExercises.first { $0.id == template.exerciseID }
    }
}
