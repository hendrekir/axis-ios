import SwiftUI
import WidgetKit
import AppIntents

struct AxisHomeWidgetView: View {
    let entry: AxisSignalEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: entry.iconName)
                        .foregroundStyle(tintColor)
                    Text(entry.title)
                        .font(.headline)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
                if let primary = entry.primaryAction {
                    Button(intent: primaryIntent()) {
                        Text(primary)
                            .font(.caption.bold())
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(tintColor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                Spacer(minLength: 0)
                if let secondary = entry.secondaryAction {
                    Button(intent: secondaryIntent()) {
                        Text(secondary)
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(4)
    }

    private var tintColor: Color {
        switch entry.state {
        case "departure_alert", "now_signal": return .red
        case "meeting_prep", "silence_detected": return .orange
        case "today_signal": return .blue
        case "morning_brief": return .yellow
        default: return .gray
        }
    }

    private func primaryIntent() -> any AppIntent {
        switch entry.state {
        case "departure_alert":
            return OpenMapsIntent(destination: entry.destination ?? "")
        case "morning_brief":
            return OpenBriefIntent()
        default:
            return MarkDoneIntent()
        }
    }

    private func secondaryIntent() -> any AppIntent {
        switch entry.state {
        case "departure_alert", "now_signal":
            return SnoozeIntent()
        default:
            return DismissIntent()
        }
    }
}
