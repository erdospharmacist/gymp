import SwiftUI

struct WorkoutSummaryHeaderView: View {
    let title: String
    let duration: String
    let volume: String
    let totalSets: Int
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button("finish") {
                    onFinish()
                }
                .buttonStyle(.bordered)
                .font(.headline)
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
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    //builds one metric in the workout summary header
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}
