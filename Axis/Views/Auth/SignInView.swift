import SwiftUI
import AuthenticationServices
import ClerkKit

struct SignInView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isSigningIn = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Logo + tagline
            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.accentColor)

                Text("Axis")
                    .font(.system(size: 44, weight: .bold, design: .rounded))

                Text("Be phone lazy.\nBe world productive.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Sign in with Apple via Clerk
            VStack(spacing: 16) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { _ in
                    // Clerk handles the Apple credential flow directly,
                    // but we keep the native button for the UI.
                    // Actual auth happens in signInWithClerk() below.
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .allowsHitTesting(false) // Disable native — overlay handles tap

                .overlay {
                    // Invisible tap target that calls Clerk's flow
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            signInWithClerk()
                        }
                }

                if isSigningIn {
                    ProgressView()
                        .padding(.top, 4)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            .disabled(isSigningIn)

            // Terms
            Text("By signing in you agree to the Terms of Service and Privacy Policy.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
                .padding(.bottom, 24)
        }
    }

    private func signInWithClerk() {
        isSigningIn = true
        errorMessage = nil

        Task {
            do {
                // Clerk handles the full Apple Sign-In flow:
                // presents the Apple sheet, extracts the ID token,
                // creates or signs in the user, and activates the session.
                try await Clerk.shared.auth.signInWithApple()

                // Grab the session token and cache in Keychain for APIService
                if let token = try await Clerk.shared.auth.getToken() {
                    KeychainService.shared.set(.clerkJWT, value: token)
                }
            } catch {
                let nsError = error as NSError
                // Don't show error for user cancellation
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
}

#Preview {
    SignInView()
}
