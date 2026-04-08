import SwiftUI
import UIKit
import UserNotifications
import ClerkKit

@main
struct AxisApp: App {
    @State private var clerk = Clerk.configure(
        publishableKey: "pk_test_cHJpbWFyeS1wb2xsaXdvZy03MC5jbGVyay5hY2NvdW50cy5kZXYk" // TODO: Replace with real key
    )

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    AppRouter.shared.handle(url)
                }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Wire the notification center delegate and register categories on launch.
        // We do NOT request permission here — that happens after first capture.
        UNUserNotificationCenter.current().delegate = NotificationService.shared
        NotificationService.shared.registerNotificationCategories()
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        NotificationService.shared.handleDeviceToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[Notifications] APNs registration failed: \(error)")
    }
}
