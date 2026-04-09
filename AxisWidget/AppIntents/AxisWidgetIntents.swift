import AppIntents
import WidgetKit
import Foundation

private let appGroup = "group.com.dreyco.axis.shared"
private let defaultBaseURL = "https://web-production-32f5d.up.railway.app"

private func postSignalAction(_ path: String) async {
    let defaults = UserDefaults(suiteName: appGroup)
    let base = defaults?.string(forKey: "apiBaseURL") ?? defaultBaseURL
    guard let url = URL(string: base + path) else { return }
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let token = defaults?.string(forKey: "authToken"), !token.isEmpty {
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    #if DEBUG
    req.setValue("1", forHTTPHeaderField: "X-Simulator-Bypass")
    #endif
    _ = try? await URLSession.shared.data(for: req)
}

struct MarkDoneIntent: AppIntent {
    static var title: LocalizedStringResource = "Mark Done"
    static var description = IntentDescription("Complete the top Axis signal.")

    func perform() async throws -> some IntentResult {
        await postSignalAction("/signal/top/complete")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct SnoozeIntent: AppIntent {
    static var title: LocalizedStringResource = "Snooze"
    static var description = IntentDescription("Snooze the top Axis signal.")

    func perform() async throws -> some IntentResult {
        await postSignalAction("/signal/top/snooze")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct DismissIntent: AppIntent {
    static var title: LocalizedStringResource = "Dismiss"
    static var description = IntentDescription("Dismiss the top Axis signal.")

    func perform() async throws -> some IntentResult {
        await postSignalAction("/signal/top/dismiss")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct OpenBriefIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Brief"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & OpensIntent {
        return .result(opensIntent: self)
    }
}

struct OpenMapsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Maps"
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Destination")
    var destination: String

    init() {
        self.destination = ""
    }

    init(destination: String) {
        self.destination = destination
    }

    func perform() async throws -> some IntentResult & OpensIntent {
        let encoded = destination.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?daddr=\(encoded)") {
            #if canImport(UIKit)
            await MainActor.run {
                // Widget extensions can't open URLs directly; use OpensIntent with a wrapper
                _ = url
            }
            #endif
        }
        return .result(opensIntent: self)
    }
}
