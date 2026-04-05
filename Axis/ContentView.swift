import SwiftUI
import ClerkKit

struct ContentView: View {
    var body: some View {
        #if targetEnvironment(simulator)
        SimulatorGate()
        #else
        AuthGate()
        #endif
    }
}

// MARK: - Onboarding Gate

struct OnboardingGate: View {
    var onSignedOut: () -> Void
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            MainTabView(onSignedOut: onSignedOut)
        } else {
            OnboardingFlow(onComplete: {
                hasCompletedOnboarding = true
            })
        }
    }
}

// MARK: - Simulator Gate (bypass Clerk, Sign in with Apple not supported)

struct SimulatorGate: View {
    @State private var isSignedIn = false

    var body: some View {
        if isSignedIn {
            OnboardingGate(onSignedOut: {
                isSignedIn = false
            })
        } else {
            SignInView(onSimulatorSignIn: {
                isSignedIn = true
            })
        }
    }
}

// MARK: - Auth Gate (device only — real Clerk auth)

struct AuthGate: View {
    @State private var isLoaded = false

    private var isSignedIn: Bool {
        Clerk.shared.session != nil
    }

    var body: some View {
        Group {
            if !isLoaded {
                ProgressView("Loading...")
                    .tint(Color.accentColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.axisBackground)
            } else if isSignedIn {
                OnboardingGate(onSignedOut: {
                    Task {
                        try? await Clerk.shared.session?.revoke()
                    }
                })
            } else {
                SignInView()
            }
        }
        .task {
            while !Clerk.shared.isLoaded {
                try? await Task.sleep(for: .milliseconds(100))
            }
            isLoaded = true
        }
    }
}

#Preview {
    ContentView()
}
