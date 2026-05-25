import Foundation
import TrainingCore

struct ExerciseProgressChoice: Identifiable, Hashable {
    let id: String
    let name: String
    let isDeleted: Bool
}

struct ExerciseProgressEntry: Identifiable, Hashable {
    let id: UUID
    let session: WorkoutSession
    let weightMoved: Double
    let totalSets: Int

    //creates a progress entry from one logged workout session
    init(session: WorkoutSession, weightMoved: Double, totalSets: Int) {
        self.id = session.id
        self.session = session
        self.weightMoved = weightMoved
        self.totalSets = totalSets
    }
}
