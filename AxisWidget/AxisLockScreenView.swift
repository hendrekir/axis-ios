import SwiftUI
import WidgetKit

struct AxisLockScreenView: View {
    let entry: AxisSignalEntry

    var body: some View {
        Link(destination: URL(string: "axis://signal")!) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: entry.iconName)
                        .widgetAccentable()
                    Text(entry.title)
                        .font(.system(size: 13, weight: .semibold))
                        .widgetAccentable()
                        .lineLimit(1)
                }
                Text(entry.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .tint(tintColor)
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
}
