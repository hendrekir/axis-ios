import Foundation
import UIKit
import UserNotifications

/// Handles APNs registration, notification categories, and action routing.
///
/// 6 notification categories from LOCKSCREEN_SPEC.md:
///   - DEPARTURE_ALERT  → [Open Maps] [Got it]
///   - NOW_SIGNAL       → [Handle] [Snooze 2h]
///   - MEETING_PREP     → [Read brief] [Dismiss]
///   - SILENCE_DETECTED → [Follow up] [Remind me in 3 days]
///   - EMAIL_DRAFT      → [Send] [Edit] [Later]
///   - MORNING_BRIEF    → [Play] [Open]
final class NotificationService: NSObject {
    static let shared = NotificationService()

    private override init() { super.init() }

    // MARK: - Categories

    func registerNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let openMaps  = UNNotificationAction(identifier: "OPEN_MAPS",  title: "Open Maps", options: [.foreground])
        let gotIt     = UNNotificationAction(identifier: "GOT_IT",     title: "Got it",    options: [])
        let handle    = UNNotificationAction(identifier: "HANDLE",     title: "Handle",    options: [.foreground])
        let snooze2h  = UNNotificationAction(identifier: "SNOOZE_2H",  title: "Snooze 2h", options: [])
        let readBrief = UNNotificationAction(identifier: "READ_BRIEF", title: "Read brief", options: [.foreground])
        let dismiss   = UNNotificationAction(identifier: "DISMISS",    title: "Dismiss",   options: [])
        let followUp  = UNNotificationAction(identifier: "FOLLOW_UP",  title: "Follow up", options: [.foreground])
        let remind3d  = UNNotificationAction(identifier: "REMIND_3D",  title: "Remind me in 3 days", options: [])
        let send      = UNNotificationAction(identifier: "SEND",       title: "Send",      options: [])
        let edit      = UNNotificationAction(identifier: "EDIT",       title: "Edit",      options: [.foreground])
        let later     = UNNotificationAction(identifier: "LATER",      title: "Later",     options: [])
        let play      = UNNotificationAction(identifier: "PLAY",       title: "Play",      options: [.foreground])
        let open      = UNNotificationAction(identifier: "OPEN",       title: "Open",      options: [.foreground])

        let departure = UNNotificationCategory(
            identifier: "DEPARTURE_ALERT",
            actions: [openMaps, gotIt],
            intentIdentifiers: [],
            options: []
        )
        let nowSignal = UNNotificationCategory(
            identifier: "NOW_SIGNAL",
            actions: [handle, snooze2h],
            intentIdentifiers: [],
            options: []
        )
        let meetingPrep = UNNotificationCategory(
            identifier: "MEETING_PREP",
            actions: [readBrief, dismiss],
            intentIdentifiers: [],
            options: []
        )
        let silence = UNNotificationCategory(
            identifier: "SILENCE_DETECTED",
            actions: [followUp, remind3d],
            intentIdentifiers: [],
            options: []
        )
        let emailDraft = UNNotificationCategory(
            identifier: "EMAIL_DRAFT",
            actions: [send, edit, later],
            intentIdentifiers: [],
            options: []
        )
        let morningBrief = UNNotificationCategory(
            identifier: "MORNING_BRIEF",
            actions: [play, open],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([
            departure, nowSignal, meetingPrep, silence, emailDraft, morningBrief
        ])
    }

    // MARK: - Permission

    /// Asks the user for notification permission. Call this AFTER first capture
    /// (from Step3Confirmation), not on app launch.
    func requestPermission() {
        Task {
            let center = UNUserNotificationCenter.current()
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                print("[Notifications] permission granted: \(granted)")
                if granted {
                    await MainActor.run {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            } catch {
                print("[Notifications] permission error: \(error)")
            }
        }
    }

    // MARK: - Device token

    func handleDeviceToken(_ deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("[Notifications] APNs token: \(tokenString)")
        Task {
            do {
                try await APIService.shared.registerDeviceToken(tokenString)
            } catch {
                print("[Notifications] failed to POST device token: \(error)")
            }
        }
    }

    // MARK: - Action routing

    @MainActor
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let identifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        let destination = userInfo["destination"] as? String
        let meetingId = userInfo["meeting_id"] as? String
        let threadId = userInfo["thread_id"] as? String

        print("[Notifications] action=\(identifier)")

        switch identifier {
        case "HANDLE":
            Task { try? await APIService.shared.completeTopSignal() }

        case "SNOOZE_2H":
            Task { try? await APIService.shared.snoozeTopSignal(hours: 2) }

        case "GOT_IT", "DISMISS":
            Task { try? await APIService.shared.dismissTopSignal() }

        case "REMIND_3D":
            Task { try? await APIService.shared.snoozeTopSignal(hours: 72) }

        case "LATER":
            Task { try? await APIService.shared.snoozeTopSignal(hours: 4) }

        case "SEND":
            Task { try? await APIService.shared.sendPendingDraft() }

        case "EDIT":
            AppRouter.shared.open(URL(string: threadId.map { "axis://thread?id=\($0)" } ?? "axis://thread"))

        case "READ_BRIEF":
            AppRouter.shared.open(URL(string: meetingId.map { "axis://meeting/\($0)" } ?? "axis://brief"))

        case "OPEN_MAPS":
            openInAppleMaps(destination: destination)

        case "FOLLOW_UP":
            AppRouter.shared.open(URL(string: threadId.map { "axis://thread?id=\($0)&prefill=1" } ?? "axis://thread"))

        case "PLAY":
            AppRouter.shared.open(URL(string: "axis://brief?play=1"))

        case "OPEN":
            AppRouter.shared.open(URL(string: "axis://brief"))

        case UNNotificationDefaultActionIdentifier:
            AppRouter.shared.open(URL(string: "axis://situation"))

        default:
            print("[Notifications] unhandled action: \(identifier)")
        }
    }

    private func openInAppleMaps(destination: String?) {
        let query = destination?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "http://maps.apple.com/?daddr=\(query)&dirflg=d")!
        Task { @MainActor in
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Task { @MainActor in
            handleNotificationResponse(response)
            completionHandler()
        }
    }
}
