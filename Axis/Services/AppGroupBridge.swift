import Foundation

/// Writes auth token + API base URL into the shared App Group so the
/// AxisWidget extension can read them for its own network calls.
enum AppGroupBridge {
    static let suiteName = "group.com.dreyco.axis.shared"
    static let tokenKey = "authToken"
    static let baseURLKey = "apiBaseURL"

    static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    static func setToken(_ token: String?) {
        guard let defaults else { return }
        if let token, !token.isEmpty {
            defaults.set(token, forKey: tokenKey)
        } else {
            defaults.removeObject(forKey: tokenKey)
        }
    }

    static func setBaseURL(_ url: String) {
        defaults?.set(url, forKey: baseURLKey)
    }
}
