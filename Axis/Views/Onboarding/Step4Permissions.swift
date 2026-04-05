import SwiftUI

struct Step4Privacy: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 56)

                Text("What Axis reads.")
                    .font(.axisSyne(28))
                    .foregroundColor(.white)

                Spacer().frame(height: AxisSpacing.xl)

                // What Axis reads
                VStack(alignment: .leading, spacing: AxisSpacing.sm) {
                    PrivacyRow(icon: "envelope.fill", text: "Email subjects and content (when connected)")
                    PrivacyRow(icon: "calendar", text: "Calendar events and attendees")
                    PrivacyRow(icon: "bubble.left.fill", text: "What you capture and tell Axis")
                    PrivacyRow(icon: "brain.head.profile", text: "Patterns it learns from your behaviour")
                }

                Spacer().frame(height: AxisSpacing.xxl)

                Text("What Axis never does.")
                    .font(.axisSyne(22))
                    .foregroundColor(.white)

                Spacer().frame(height: AxisSpacing.md)

                VStack(alignment: .leading, spacing: AxisSpacing.sm) {
                    NeverRow(text: "Sell or share your data with anyone")
                    NeverRow(text: "Send anything without your approval")
                    NeverRow(text: "Act on its own — you always confirm")
                    NeverRow(text: "Train models on your personal data")
                }

                Spacer().frame(height: AxisSpacing.xxl)

                Link(destination: URL(string: "https://tryaxis.app/privacy")!) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 13))
                        Text("Read full privacy policy")
                            .font(.axisBody2)
                    }
                    .foregroundColor(.axisViolet)
                }
            }
            .padding(.horizontal, AxisSpacing.xxl)
        }
    }
}

private struct PrivacyRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.axisViolet)
                .frame(width: 20)
            Text(text)
                .font(.axisBody1)
                .foregroundColor(.axisTextSecondary)
                .lineSpacing(3)
        }
        .padding(.vertical, 4)
    }
}

private struct NeverRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.axisRed)
                .frame(width: 20)
            Text(text)
                .font(.axisBody1)
                .foregroundColor(.axisTextSecondary)
                .lineSpacing(3)
        }
        .padding(.vertical, 4)
    }
}
