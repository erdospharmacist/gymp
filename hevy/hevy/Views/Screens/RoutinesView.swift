import SwiftUI

struct RoutinesView: View {

    @StateObject private var routineViewModel = RoutineListViewModel()
    @StateObject private var exerciseViewModel = ExerciseListViewModel()

    @State private var showingNewRoutineAlert = false
    @State private var newRoutineName = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    //
                    Button {
                        showingNewRoutineAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("New Routine")
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.green))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .listRowBackground(Color.clear)
                }

                // Section for routine cards
                Section {
                    if routineViewModel.routines.isEmpty {
                        VStack(spacing: 10) {
                            Text("No routines yet")
                                .font(.headline)

                            Text("Tap “New Routine” to create your first routine.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(routineViewModel.routines) { routine in
                            RoutineCardView(
                                routine: routine,
                                allExercises: exerciseViewModel.exercises,
                                routineViewModel: routineViewModel,
                                onDelete: {
                                    routineViewModel.deleteRoutine(routine)
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onMove(perform: moveRoutine)
                    }
                } header: {
                    Text("My Routines (\(routineViewModel.routines.count))")
                }
            }
            .listStyle(.plain)
            .background(Color(.systemGray6))
            .navigationTitle("Routines")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditButton()
            }
            .alert("New Routine", isPresented: $showingNewRoutineAlert) {
                TextField("Routine name", text: $newRoutineName)

                Button("Create") {
                    routineViewModel.addRoutine(named: newRoutineName)
                    newRoutineName = ""
                }

                Button("Cancel", role: .cancel) {
                    newRoutineName = ""
                }
            } message: {
                Text("Enter a name for your new routine.")
            }
        }
    }

    //reorders routines in the visible list while editing
    private func moveRoutine(from source: IndexSet, to destination: Int) {
        routineViewModel.moveRoutine(from: source, to: destination)
    }
}
