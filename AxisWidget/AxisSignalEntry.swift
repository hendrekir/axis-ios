import WidgetKit
import Foundation

struct AxisSignalEntry: TimelineEntry {
    let date: Date
    let state: String
    let title: String
    let subtitle: String
    let iconName: String
    let primaryAction: String?
    let secondaryAction: String?
    let signalId: String?
    let destination: String?

    static let idle = AxisSignalEntry(
        date: Date(),
        state: "idle",
        title: "Axis is watching",
        subtitle: "Tap to capture",
        iconName: "eye.fill",
        primaryAction: nil,
        secondaryAction: nil,
        signalId: nil,
        destination: nil
    )
}

enum AxisSignalState {
    static func icon(for state: String) -> String {
        switch state {
        case "departure_alert": return "car.fill"
        case "now_signal": return "exclamationmark.circle.fill"
        case "meeting_prep": return "calendar"
        case "silence_detected": return "waveform"
        case "today_signal": return "bell.fill"
        case "morning_brief": return "sun.max.fill"
        default: return "eye.fill"
        }
    }
}
