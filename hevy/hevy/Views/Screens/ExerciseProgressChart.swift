import SwiftUI

struct ExerciseProgressChart: View {
    let entries: [ExerciseProgressEntry]
    let maxWeight: Double

    var body: some View {
        GeometryReader { geometry in
            //keep bars visible even if there are lots of logged workouts
            let barWidth = max(
                CGFloat(6),
                (geometry.size.width - CGFloat(max(entries.count - 1, 0)) * 6) / CGFloat(max(entries.count, 1))
            )

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(entries) { entry in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.green)
                        .frame(
                            width: barWidth,
                            height: barHeight(
                                entry.weightMoved,
                                availableHeight: geometry.size.height
                            )
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(height: 110)
        .padding(.vertical, 8)
    }

    //converts a workout's total volume into a chart bar height
    private func barHeight(_ weightMoved: Double, availableHeight: CGFloat) -> CGFloat {
        //small minimum means a zero-light workout still has a visible bar
        guard maxWeight > 0 else { return 4 }
        return max(4, availableHeight * CGFloat(weightMoved / maxWeight))
    }
}
