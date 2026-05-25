import Foundation

public enum MockTrainingData {
    //fixed IDs keep previews stable and make routine/workout links easy to inspect
    public static let hamstringExerciseID = "90_90_Hamstring"
    public static let benchPressExerciseID = "Barbell_Bench_Press"
    public static let squatExerciseID = "Barbell_Back_Squat"

    public static let upperBodyRoutineID = "mock_upper_body"
    public static let lowerBodyRoutineID = "mock_lower_body"

    //mock exercise catalog used by previews that need selectable exercises
    public static var hamstring: Exercise {
        Exercise(
            id: hamstringExerciseID,
            name: "90/90 Hamstring",
            force: "pull",
            level: "beginner",
            mechanic: "isolation",
            equipment: "body only",
            primaryMuscles: ["hamstrings"],
            secondaryMuscles: ["glutes"],
            instructions: [
                "Lie on your back with one leg raised and the knee bent.",
                "Extend the raised leg until you feel a hamstring stretch.",
                "Return with control and repeat."
            ],
            category: "stretching",
            images: []
        )
    }

    public static var benchPress: Exercise {
        Exercise(
            id: benchPressExerciseID,
            name: "Barbell Bench Press",
            force: "push",
            level: "beginner",
            mechanic: "compound",
            equipment: "barbell",
            primaryMuscles: ["chest"],
            secondaryMuscles: ["triceps", "shoulders"],
            instructions: [
                "Lie on the bench with your eyes under the bar.",
                "Lower the bar to your chest with control.",
                "Press the bar back up until your arms are extended."
            ],
            category: "strength",
            images: []
        )
    }

    public static var squat: Exercise {
        Exercise(
            id: squatExerciseID,
            name: "Barbell Back Squat",
            force: "push",
            level: "intermediate",
            mechanic: "compound",
            equipment: "barbell",
            primaryMuscles: ["quadriceps"],
            secondaryMuscles: ["glutes", "hamstrings"],
            instructions: [
                "Set the bar across your upper back.",
                "Sit down between your hips while keeping your chest up.",
                "Drive through your feet to stand back up."
            ],
            category: "strength",
            images: []
        )
    }

    public static var exercises: [Exercise] {
        [
            hamstring,
            benchPress,
            squat
        ]
    }

    //routines store exercise templates rather than full exercise definitions
    public static var upperBodyRoutine: Routine {
        Routine(
            id: upperBodyRoutineID,
            name: "Upper Body",
            exerciseTemplates: [
                RoutineExerciseTemplate(
                    exerciseID: hamstringExerciseID,
                    targetSets: 3,
                    targetReps: 12,
                    notes: "Warm up the posterior chain"
                ),
                RoutineExerciseTemplate(
                    exerciseID: benchPressExerciseID,
                    targetSets: 3,
                    targetReps: 8,
                    notes: "Use a controlled pause"
                )
            ]
        )
    }

    public static var lowerBodyRoutine: Routine {
        Routine(
            id: lowerBodyRoutineID,
            name: "Lower Body",
            exerciseTemplates: [
                RoutineExerciseTemplate(
                    exerciseID: squatExerciseID,
                    targetSets: 4,
                    targetReps: 5,
                    notes: "Add weight only if form stays clean"
                )
            ]
        )
    }

    public static var routines: [Routine] {
        [
            upperBodyRoutine,
            lowerBodyRoutine
        ]
    }

    //fixed dates keep preview ordering and workout durations predictable
    private static let upperBodyWorkoutStart = Date(timeIntervalSince1970: 1_778_726_400)
    private static let upperBodyProgressWorkoutStart = Date(timeIntervalSince1970: 1_779_244_800)
    private static let lowerBodyWorkoutStart = Date(timeIntervalSince1970: 1_779_417_600)
    private static let activeWorkoutStart = Date(timeIntervalSince1970: 1_779_504_000)

    //workout exercise IDs are separate from exercise IDs because each logged block is its own row
    public static var upperBodyWorkout: WorkoutSession {
        WorkoutSession(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            routineID: upperBodyRoutineID,
            name: "Upper Body",
            startedAt: upperBodyWorkoutStart,
            endedAt: upperBodyWorkoutStart.addingTimeInterval(45 * 60),
            exercises: [
                WorkoutExercise(
                    id: UUID(uuidString: "11111111-1111-1111-1111-111111111119")!,
                    exerciseID: hamstringExerciseID,
                    exerciseNameSnapshot: "90/90 Hamstring",
                    sets: [
                        WorkoutSet(id: UUID(uuidString: "11111111-1111-1111-1111-111111111201")!, weight: 65, reps: 12, isCompleted: true),
                        WorkoutSet(id: UUID(uuidString: "11111111-1111-1111-1111-111111111202")!, weight: 65, reps: 12, isCompleted: true),
                        WorkoutSet(id: UUID(uuidString: "11111111-1111-1111-1111-111111111203")!, weight: 65, reps: 12, isCompleted: true)
                    ]
                ),
                WorkoutExercise(
                    id: UUID(uuidString: "11111111-1111-1111-1111-111111111129")!,
                    exerciseID: benchPressExerciseID,
                    exerciseNameSnapshot: "Barbell Bench Press",
                    sets: [
                        WorkoutSet(id: UUID(uuidString: "11111111-1111-1111-1111-111111111301")!, weight: 40, reps: 8, isCompleted: true),
                        WorkoutSet(id: UUID(uuidString: "11111111-1111-1111-1111-111111111302")!, weight: 40, reps: 8, isCompleted: true),
                        WorkoutSet(id: UUID(uuidString: "11111111-1111-1111-1111-111111111303")!, weight: 40, reps: 8, isCompleted: true)
                    ]
                )
            ]
        )
    }

    public static var upperBodyProgressWorkout: WorkoutSession {
        WorkoutSession(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            routineID: upperBodyRoutineID,
            name: "Upper Body",
            startedAt: upperBodyProgressWorkoutStart,
            endedAt: upperBodyProgressWorkoutStart.addingTimeInterval(48 * 60),
            exercises: [
                WorkoutExercise(
                    id: UUID(uuidString: "22222222-2222-2222-2222-222222222219")!,
                    exerciseID: hamstringExerciseID,
                    exerciseNameSnapshot: "90/90 Hamstring",
                    sets: [
                        WorkoutSet(id: UUID(uuidString: "22222222-2222-2222-2222-222222222201")!, weight: 70, reps: 12, isCompleted: true),
                        WorkoutSet(id: UUID(uuidString: "22222222-2222-2222-2222-222222222202")!, weight: 70, reps: 12, isCompleted: true),
                        WorkoutSet(id: UUID(uuidString: "22222222-2222-2222-2222-222222222203")!, weight: 70, reps: 12, isCompleted: true)
                    ]
                ),
                WorkoutExercise(
                    id: UUID(uuidString: "22222222-2222-2222-2222-222222222229")!,
                    exerciseID: benchPressExerciseID,
                    exerciseNameSnapshot: "Barbell Bench Press",
                    sets: [
                        WorkoutSet(id: UUID(uuidString: "22222222-2222-2222-2222-222222222301")!, weight: 45, reps: 8, isCompleted: true),
                        WorkoutSet(id: UUID(uuidString: "22222222-2222-2222-2222-222222222302")!, weight: 45, reps: 8, isCompleted: true),
                        WorkoutSet(id: UUID(uuidString: "22222222-2222-2222-2222-222222222303")!, weight: 45, reps: 8, isCompleted: true)
                    ]
                )
            ]
        )
    }

    public static var lowerBodyWorkout: WorkoutSession {
        WorkoutSession(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            routineID: lowerBodyRoutineID,
            name: "Lower Body",
            startedAt: lowerBodyWorkoutStart,
            endedAt: lowerBodyWorkoutStart.addingTimeInterval(52 * 60),
            exercises: [
                WorkoutExercise(
                    id: UUID(uuidString: "33333333-3333-3333-3333-333333333339")!,
                    exerciseID: squatExerciseID,
                    exerciseNameSnapshot: "Barbell Back Squat",
                    sets: [
                        WorkoutSet(id: UUID(uuidString: "33333333-3333-3333-3333-333333333301")!, weight: 80, reps: 5, isCompleted: true),
                        WorkoutSet(id: UUID(uuidString: "33333333-3333-3333-3333-333333333302")!, weight: 80, reps: 5, isCompleted: true),
                        WorkoutSet(id: UUID(uuidString: "33333333-3333-3333-3333-333333333303")!, weight: 82.5, reps: 5, isCompleted: true),
                        WorkoutSet(id: UUID(uuidString: "33333333-3333-3333-3333-333333333304")!, weight: 82.5, reps: 5, isCompleted: true)
                    ]
                )
            ]
        )
    }

    //an unfinished workout is useful for previews of the active workout screen
    public static var activeWorkout: WorkoutSession {
        WorkoutSession(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
            routineID: upperBodyRoutineID,
            name: "Upper Body",
            startedAt: activeWorkoutStart,
            endedAt: nil,
            exercises: [
                WorkoutExercise(
                    id: UUID(uuidString: "44444444-4444-4444-4444-444444444429")!,
                    exerciseID: benchPressExerciseID,
                    exerciseNameSnapshot: "Barbell Bench Press",
                    sets: [
                        WorkoutSet(id: UUID(uuidString: "44444444-4444-4444-4444-444444444401")!, weight: 45, reps: 8, isCompleted: true, previousWeight: 45, previousReps: 8),
                        WorkoutSet(id: UUID(uuidString: "44444444-4444-4444-4444-444444444402")!, weight: 45, reps: 8, isCompleted: false, previousWeight: 45, previousReps: 8),
                        WorkoutSet(id: UUID(uuidString: "44444444-4444-4444-4444-444444444403")!, weight: 45, reps: 8, isCompleted: false, previousWeight: 45, previousReps: 8)
                    ]
                )
            ]
        )
    }

    public static var workoutSessions: [WorkoutSession] {
        [
            upperBodyWorkout,
            upperBodyProgressWorkout,
            lowerBodyWorkout
        ]
    }

    public static var workouts: [WorkoutSession] {
        workoutSessions
    }
}
