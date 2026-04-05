import SwiftUI
import AuthenticationServices
import ClerkKit

struct SignInView: View {
    /// On simulator, this closure bypasses Clerk and goes straight to MainTabView.
    var onSimulatorSignIn: (() -> Void)? = nil

    @State private var isSigningIn = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo + branding
            VStack(spacing: 20) {
                Text("AXIS")
                    .font(.system(size: 56, weight: .heavy, design: .default))
                    .tracking(12)
                    .foregroundStyle(Color.accentColor)

                Text("Be phone lazy.\nBe world productive.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Sign in section
            VStack(spacing: 16) {
                #if targetEnvironment(simulator)
                // Simulator: bypass Sign in with Apple (not supported)
                Button {
                    onSimulatorSignIn?()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "person.fill")
                        Text("Continue as Test User")
                            .font(.body.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                }
                #else
                // Device: real Sign in with Apple via Clerk
                Button {
                    signInWithClerk()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "apple.logo")
                        Text("Continue with Apple")
                            .font(.body.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                }
                .disabled(isSigningIn)
                #endif

                if isSigningIn {
                    ProgressView()
                        .tint(Color.accentColor)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)

            Spacer()
                .frame(height: 40)

            // Terms
            Text("By signing in you agree to the Terms of Service and Privacy Policy.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
                .padding(.bottom, 24)
        }
        .background(Color.axisBackground)
    }

    #if !targetEnvironment(simulator)
    private func signInWithClerk() {
        isSigningIn = true
        errorMessage = nil

        Task {
            do {
                try await Clerk.shared.auth.signInWithApple()
            } catch {
                let nsError = error as NSError
                if nsError.domain == ASAuthorizationErrorDomain
                    && nsError.code == ASAuthorizationError.canceled.rawValue {
                    // User cancelled — silent
                } else {
                    errorMessage = error.localizedDescription
                }
            }
            isSigningIn = false
        }
    }
    #endif
}

#Preview {
    SignInView()
}
