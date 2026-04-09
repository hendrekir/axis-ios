import WidgetKit
import Foundation

struct AxisSignalProvider: TimelineProvider {
    static let appGroup = "group.com.dreyco.axis.shared"
    static let defaultBaseURL = "https://web-production-32f5d.up.railway.app"

    func placeholder(in context: Context) -> AxisSignalEntry {
        .idle
    }

    func getSnapshot(in context: Context, completion: @escaping (AxisSignalEntry) -> Void) {
        completion(.idle)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AxisSignalEntry>) -> Void) {
        Task {
            let entry = await fetchEntry()
            let interval: TimeInterval = entry.state == "departure_alert" ? 60 : 15 * 60
            let next = Date().addingTimeInterval(interval)
            let timeline = Timeline(entries: [entry], policy: .after(next))
            completion(timeline)
        }
    }

    private func fetchEntry() async -> AxisSignalEntry {
        let defaults = UserDefaults(suiteName: Self.appGroup)
        let baseURLString = defaults?.string(forKey: "apiBaseURL") ?? Self.defaultBaseURL
        guard let url = URL(string: baseURLString + "/me/widget-data") else {
            return .idle
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = defaults?.string(forKey: "authToken"), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        #if DEBUG
        request.setValue("1", forHTTPHeaderField: "X-Simulator-Bypass")
        #endif

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                return .idle
            }
            guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return .idle
            }
            let state = obj["state"] as? String ?? "idle"
            return AxisSignalEntry(
                date: Date(),
                state: state,
                title: obj["title"] as? String ?? "Axis is watching",
                subtitle: obj["subtitle"] as? String ?? "Tap to capture",
                iconName: (obj["icon_name"] as? String) ?? AxisSignalState.icon(for: state),
                primaryAction: obj["primary_action"] as? String,
                secondaryAction: obj["secondary_action"] as? String,
                signalId: obj["signal_id"] as? String,
                destination: obj["destination"] as? String
            )
        } catch {
            return .idle
        }
    }
}
