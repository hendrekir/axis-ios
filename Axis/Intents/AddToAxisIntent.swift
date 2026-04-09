import AppIntents
import Foundation

/// "Hey Siri, add to Axis: [text]" / "Hey Siri, tell Axis: [anything]"
/// Captures any text and sends it to the backend for classification.
struct AddToAxisIntent: AppIntent {
    static var title: LocalizedStringResource = "Add to Axis"
    static var description = IntentDescription("Capture a thought, task, or reminder in Axis.")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Text")
    var text: String

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$text) to Axis")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults(suiteName: "group.com.dreyco.axis.shared")
        let base = defaults?.string(forKey: "apiBaseURL")
            ?? "https://web-production-32f5d.up.railway.app"
        guard let url = URL(string: base + "/capture") else {
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

        let body: [String: Any] = ["raw_text": text, "source": "siri"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        _ = try? await URLSession.shared.data(for: request)
        return .result(dialog: "Got it. Captured.")
    }
}
