import SwiftUI
import UserNotifications

struct Step4Permissions: View {
    @State private var notificationsGranted = false
    @State private var locationGranted = false
    @State private var healthGranted = false
    @State private var contactsGranted = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 56)

                Text("One-time setup.")
                    .font(.axisSyne(28))
                    .foregroundColor(.white)

                Spacer().frame(height: AxisSpacing.md)

                Text("These let Axis work without you having to think about it.")
                    .font(.axisBody1)
                    .foregroundColor(.axisTextSecondary)
                    .lineSpacing(4)

                Spacer().frame(height: AxisSpacing.xl)

                VStack(spacing: AxisSpacing.sm) {
                    PermissionCard(
                        emoji: "🔔",
                        title: "Notifications",
                        subtitle: "The main way Axis reaches you",
                        granted: notificationsGranted,
                        onRequest: requestNotifications
                    )
                    PermissionCard(
                        emoji: "📍",
                        title: "Location",
                        subtitle: "Auto-switch modes when you arrive",
                        granted: locationGranted,
                        onRequest: { locationGranted = true }
                    )
                    PermissionCard(
                        emoji: "❤️",
                        title: "Health",
                        subtitle: "Route tasks by your energy level",
                        granted: healthGranted,
                        onRequest: { healthGranted = true }
                    )
                    PermissionCard(
                        emoji: "👥",
                        title: "Contacts",
                        subtitle: "Know who matters in your email",
                        granted: contactsGranted,
                        onRequest: { contactsGranted = true }
                    )
                }
            }
            .padding(.horizontal, AxisSpacing.xxl)
        }
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                notificationsGranted = granted
            }
        }
    }
}

private struct PermissionCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    let granted: Bool
    let onRequest: () -> Void

    var body: some View {
        Button(action: { if !granted { onRequest() } }) {
            AxisCard {
                HStack(spacing: AxisSpacing.md) {
                    Text(emoji)
                        .font(.system(size: 24))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.axisH2)
                            .foregroundColor(.axisTextPrimary)
                        Text(subtitle)
                            .font(.axisBody2)
                            .foregroundColor(.axisTextSecondary)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(granted ? Color.axisGreen : Color.axisBorderStrong, lineWidth: 1.5)
                            .frame(width: 22, height: 22)
                        if granted {
                            Circle()
                                .fill(Color.axisGreen)
                                .frame(width: 14, height: 14)
                        }
                    }
                }
                .padding(14)
            }
        }
        .buttonStyle(.plain)
    }
}
