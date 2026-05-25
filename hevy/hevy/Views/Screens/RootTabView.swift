import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView{
            NavigationStack{
                RoutinesView()
                
            }
            .tabItem{
                Image(systemName: "figure.strengthtraining.traditional")
                Text("Workout")
            }
            
            NavigationStack {
                CalendarView()
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Calendar")
            }

            NavigationStack {
                ExerciseProgressView()
            }
            .tabItem {
                Image(systemName: "chart.bar.xaxis")
                Text("Stats")
            }
        }
    }
}
