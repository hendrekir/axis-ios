import SwiftUI
import ClerkKit

@main
struct AxisApp: App {
    @State private var clerk = Clerk.configure(
        publishableKey: "pk_test_cHJpbWFyeS1wb2xsaXdvZy03MC5jbGVyay5hY2NvdW50cy5kZXYk" // TODO: Replace with real key
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
