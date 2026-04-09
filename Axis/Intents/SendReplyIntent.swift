import AppIntents
import Foundation

/// "Hey Siri, send that Axis reply"
/// Sends the pre-drafted reply for the top signal.
struct SendReplyIntent: AppIntent {
    static var title: LocalizedStringResource = "Send Axis Reply"
    static var description = IntentDescription("Send the reply Axis drafted for your top signal.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults(suiteName: "group.com.dreyco.axis.shared")
        let base = defaults?.string(forKey: "apiBaseURL")
            ?? "https://web-production-32f5d.up.railway.app"
        guard let url = URL(string: base + "/signal/top/send-reply") else {
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
        return .result(dialog: "Reply sent.")
    }
}
