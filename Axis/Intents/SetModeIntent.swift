import AppIntents
import Foundation

/// "Hey Siri, switch Axis to Builder mode"
/// Changes the user's active mode/context.
struct SetModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Axis Mode"
    static var description = IntentDescription("Switch Axis to a different mode like Builder or Personal.")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Mode")
    var mode: String

    static var parameterSummary: some ParameterSummary {
        Summary("Switch Axis to \(\.$mode) mode")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults(suiteName: "group.com.dreyco.axis.shared")
        let base = defaults?.string(forKey: "apiBaseURL")
            ?? "https://web-production-32f5d.up.railway.app"
        guard let url = URL(string: base + "/me/mode") else {
            return .result(dialog: "Could not reach Axis.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = defaults?.string(forKey: "authToken"), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        #if targetEnvironment(simulator)
        request.setValue("true", forHTTPHeaderField: "X-Dev-Simulator")
        #endif

        let body: [String: Any] = ["mode": mode.lowercased()]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        _ = try? await URLSession.shared.data(for: request)
        return .result(dialog: "Switched to \(mode) mode.")
    }
}
