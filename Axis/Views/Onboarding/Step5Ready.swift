import SwiftUI

struct Step5Connections: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 56)

                Text("Read your world.")
                    .font(.axisSyne(28))
                    .foregroundColor(.white)

                Spacer().frame(height: AxisSpacing.md)

                Text("Connect Gmail and Calendar to let Axis read your world — not just what you tell it.")
                    .font(.axisBody1)
                    .foregroundColor(.axisTextSecondary)
                    .lineSpacing(6)

                Spacer().frame(height: AxisSpacing.xxl)

                // Gmail connect card
                ConnectServiceCard(
                    icon: "envelope.fill",
                    name: "Connect Gmail",
                    description: "Read + send email on your behalf"
                )

                Spacer().frame(height: AxisSpacing.base)

                // Calendar connect card
                ConnectServiceCard(
                    icon: "calendar",
                    name: "Connect Google Calendar",
                    description: "Meeting prep + conflict detection"
                )

                Spacer().frame(height: AxisSpacing.xl)

                // Skip — prominent, not buried
                Button("Skip for now") { }
                    .font(.axisBody(15, weight: .medium))
                    .foregroundColor(.axisTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 14)
            }
            .padding(.horizontal, AxisSpacing.xxl)
        }
    }
}

private struct ConnectServiceCard: View {
    let icon: String
    let name: String
    let description: String

    var body: some View {
        AxisCard(elevated: true) {
            VStack(alignment: .leading, spacing: AxisSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.axisViolet)

                Text(name)
                    .font(.axisH1)
                    .foregroundColor(.axisTextPrimary)

                Text(description)
                    .font(.axisBody2)
                    .foregroundColor(.axisTextSecondary)

                Button(action: { }) {
                    Text("Connect")
                        .font(.axisBody(15, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.axisViolet)
                        .cornerRadius(AxisRadius.md)
                }
                .buttonStyle(.plain)
            }
            .padding(AxisSpacing.base)
        }
    }
}
