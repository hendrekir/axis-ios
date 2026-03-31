import SwiftUI
import ClerkKit

struct ContentView: View {
    var body: some View {
        #if targetEnvironment(simulator)
        // Simulator: skip auth, go straight to app with dev token
        MainTabView(onSignedOut: {
            KeychainService.shared.delete(.clerkJWT)
        })
        .onAppear {
            if KeychainService.shared.get(.clerkJWT) == nil {
                KeychainService.shared.set(.clerkJWT, value: "dev-simulator-token")
            }
        }
        #else
        // Device: use real Clerk auth
        AuthGate()
        #endif
    }
}

// MARK: - Auth Gate (device only)

struct AuthGate: View {
    @State private var isLoaded = false

    private var isSignedIn: Bool {
        Clerk.shared.session != nil
    }

    var body: some View {
        Group {
            if !isLoaded {
                ProgressView("Loading...")
            } else if isSignedIn {
                MainTabView(onSignedOut: {
                    Task {
                        try? await Clerk.shared.session?.revoke()
                        KeychainService.shared.delete(.clerkJWT)
                    }
                })
            } else {
                SignInView()
            }
        }
        .task {
            // Wait for Clerk to load its environment
            while !Clerk.shared.isLoaded {
                try? await Task.sleep(for: .milliseconds(100))
            }
            isLoaded = true
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    var onSignedOut: () -> Void

    var body: some View {
        TabView {
            NavigationStack {
                ThreadView()
            }
            .tabItem {
                Label("Thread", systemImage: "bubble.left.fill")
            }

            NavigationStack {
                SignalView()
            }
            .tabItem {
                Label("Signal", systemImage: "bolt.fill")
            }

            NavigationStack {
                BrainDumpView()
            }
            .tabItem {
                Label("Dump", systemImage: "brain.head.profile")
            }

            NavigationStack {
                BriefView()
            }
            .tabItem {
                Label("Brief", systemImage: "sunrise.fill")
            }

            NavigationStack {
                SettingsView(onSignedOut: onSignedOut)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
}

#Preview {
    ContentView()
}
