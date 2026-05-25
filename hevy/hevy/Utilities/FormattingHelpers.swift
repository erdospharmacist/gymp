import Foundation
import SwiftUI

extension TimeInterval {
    var workoutDurationText: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes)m \(seconds)s"
    }
}

struct MainButtonModifier: ViewModifier {
    //applies the shared green primary button styling
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

extension View {
    //adds the app's shared primary button style to any SwiftUI view
    func mainButtonStyle() -> some View {
        return modifier(MainButtonModifier())
    }
}
