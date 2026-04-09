import AppIntents
import Foundation

/// "Hey Siri, what's my Axis signal?"
/// Reads the top signal aloud.
struct GetSignalIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Axis Signal"
    static var description = IntentDescription("Read your top Axis signal aloud.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults(suiteName: "group.com.dreyco.axis.shared")
        let base = defaults?.string(forKey: "apiBaseURL")
            ?? "https://web-production-32f5d.up.railway.app"
        guard let url = URL(string: base + "/signal/top") else {
            return .result(dialog: "Could not reach Axis.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = defaults?.string(forKey: "authToken"), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        #if targetEnvironment(simulator)
        request.setValue("true", forHTTPHeaderField: "X-Dev-Simulator")
        #endif

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let title = json["title"] as? String else {
            return .result(dialog: "Nothing urgent right now. You're clear.")
        }

        return .result(dialog: "\(title)")
    }
}
