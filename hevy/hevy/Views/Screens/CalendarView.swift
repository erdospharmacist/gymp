import SwiftUI
import TrainingCore

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var sessions: [WorkoutSession] = []
    @State private var errorMessage: String?

    private let previewSessions: [WorkoutSession]?
    private let calendar = Calendar.current

    //allows previews to inject mock sessions without changing how the real app loads saved sessions
    init(previewSessions: [WorkoutSession]? = nil) {
        self.previewSessions = previewSessions
        _sessions = State(initialValue: previewSessions ?? [])
        _selectedDate = State(initialValue: previewSessions?.first?.startedAt ?? Date())
    }

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
            //previews already have mock sessions, so only the real app reads from saved storage
            if previewSessions == nil {
                loadSessions()
            }
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

private enum CalendarPreviewData {
    private struct MockTrainingData: Decodable {
        let workout: WorkoutSession
    }

    //loads the workout from mock_training_data.json for the Calendar preview
    static var sessions: [WorkoutSession] {
        guard let url = mockDataURL else { return [] }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return [try decoder.decode(MockTrainingData.self, from: data).workout]
        } catch {
            print("failed loading calendar preview data: \(error)")
            return []
        }
    }

    //finds the package resource whether Xcode exposes the resource bundle directly or nests it in the app bundle
    private static var mockDataURL: URL? {
        let bundles = Bundle.allBundles + Bundle.allFrameworks

        if let url = bundles.compactMap({ $0.url(forResource: "mock_training_data", withExtension: "json") }).first {
            return url
        }

        guard let resourceURL = Bundle.main.resourceURL,
              let fileURLs = FileManager.default.enumerator(at: resourceURL, includingPropertiesForKeys: nil) else {
            return nil
        }

        for case let fileURL as URL in fileURLs where fileURL.lastPathComponent == "mock_training_data.json" {
            return fileURL
        }

        return nil
    }
}

#Preview {
    NavigationStack {
        CalendarView(previewSessions: CalendarPreviewData.sessions)
    }
}
