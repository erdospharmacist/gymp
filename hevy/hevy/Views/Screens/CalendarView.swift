import SwiftUI
import TrainingCore

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var sessions: [WorkoutSession] = []
    @State private var errorMessage: String?

    private let calendar = Calendar.current

    private var sessionsForSelectedDate: [WorkoutSession] {
        sessions
            .filter { session in
                calendar.isDate(session.startedAt, inSameDayAs: selectedDate)
            }
            .sorted { $0.startedAt > $1.startedAt }
    }

    var body: some View {
        VStack(spacing: 30) {
            Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 50))
                .bold()
                .foregroundColor(.green)
                .padding(.top)

            Divider()

            //read this if i forget
            //https://developer.apple.com/documentation/swiftui/datepicker
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .font(.title)

            Divider()

            if sessionsForSelectedDate.isEmpty {
                Spacer()

                Text("No workouts logged for this day")
                    .foregroundColor(.secondary)

                Spacer()
            } else {
                List(sessionsForSelectedDate) { session in
                    NavigationLink(destination: LoggedWorkoutDetailView(session: session)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(session.name)
                                .font(.headline)

                            Text(session.startedAt.formatted(date: .omitted, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("\(session.totalSets) sets • \(session.totalVolume.kgText)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSessions()
        }
    }

    //loads saved workout sessions for the calendar list
    private func loadSessions() {
        do {
            sessions = try WorkoutSessionStore().loadSessions()
            errorMessage = nil
        } catch {
            sessions = []
            errorMessage = "Failed to load workout sessions: \(error)"
        }
    }
}

#Preview {
    CalendarView()
}
