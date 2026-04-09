import SwiftUI
import AuthenticationServices
import ClerkKit

struct SignInView: View {
    /// On simulator, this closure bypasses Clerk and goes straight to MainTabView.
    var onSimulatorSignIn: (() -> Void)? = nil
    /// On device dev-login, this closure bypasses Clerk and goes straight to MainTabView.
    var onDevLogin: (() -> Void)? = nil

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

                Text("Everything you're trying to hold\nin your head. Held.")
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

                // Google OAuth via Clerk
                Button {
                    signInWithGoogle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "g.circle.fill")
                        Text("Continue with Google")
                            .font(.body.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(.systemBackground).opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.accentColor, lineWidth: 1.5))
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

                #if DEBUG
                Button {
                    performDevLogin()
                } label: {
                    Text("Dev Login")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .disabled(isSigningIn)
                #endif
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

    // MARK: - Dev Login

    #if DEBUG
    private func performDevLogin() {
        isSigningIn = true
        errorMessage = nil

        Task {
            do {
                let url = URL(string: "https://web-production-32f5d.up.railway.app/auth/dev-login")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONEncoder().encode(["email": "hendre@tryaxis.app"])

                let (data, response) = try await URLSession.shared.data(for: request)

                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }

                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let token = json["token"] as? String else {
                    throw URLError(.cannotParseResponse)
                }

                // Store token in Keychain (same as Clerk JWT)
                KeychainService.shared.set(.clerkJWT, value: token)

                // Store in App Group for widget
                AppGroupBridge.setToken(token)

                // Set dev login flag so AuthGate knows we are signed in
                UserDefaults.standard.set(true, forKey: "devLoginActive")

                await MainActor.run {
                    isSigningIn = false
                    onDevLogin?()
                }
            } catch {
                await MainActor.run {
                    isSigningIn = false
                    errorMessage = "Dev login failed"
                }
            }
        }
    }
    #endif

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

    private func signInWithGoogle() {
        isSigningIn = true
        errorMessage = nil

        Task {
            do {
                try await Clerk.shared.auth.signInWithOAuth(provider: .google)
            } catch {
                errorMessage = error.localizedDescription
            }
            isSigningIn = false
        }
    }
    #endif
}

#Preview {
    SignInView()
}
