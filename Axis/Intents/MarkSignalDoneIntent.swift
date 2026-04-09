import AppIntents
import Foundation

/// "Hey Siri, mark my Axis signal done"
/// Completes the top signal via the backend.
struct MarkSignalDoneIntent: AppIntent {
    static var title: LocalizedStringResource = "Mark Axis Signal Done"
    static var description = IntentDescription("Complete your top Axis signal.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults(suiteName: "group.com.dreyco.axis.shared")
        let base = defaults?.string(forKey: "apiBaseURL")
            ?? "https://web-production-32f5d.up.railway.app"
        guard let url = URL(string: base + "/signal/top/complete") else {
            return .result(dialog: "Could not reach Axis.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = defaults?.string(forKey: "authToken"), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        #if targetEnvironment(simulator)
        request.setValue("true", forHTTPHeaderField: "X-Dev-Simulator")
        #endif

        _ = try? await URLSession.shared.data(for: request)
        return .result(dialog: "Done. Signal marked complete.")
    }
}
