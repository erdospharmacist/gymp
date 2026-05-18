import SwiftUI

struct WorkoutSummaryHeaderView: View {
    let title: String
    let duration: String
    let volume: String
    let totalSets: Int
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.medium)

                Spacer()

                Button("finish") {
                    onFinish()
                }
                .buttonStyle(.bordered)
                .font(.title3)
                .padding(.top, 4)
            }

            HStack {
                statItem(title: "duration", value: duration)
                Spacer()
                statItem(title: "Volume", value: volume)
                Spacer()
                statItem(title: "Sets:", value: "\(totalSets)")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.black, lineWidth: 2)
        )
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title3)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}
