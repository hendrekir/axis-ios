import WidgetKit
import SwiftUI

@main
struct AxisWidgetBundle: WidgetBundle {
    var body: some Widget {
        AxisLockScreenWidget()
        AxisHomeWidget()
    }
}

struct AxisLockScreenWidget: Widget {
    let kind: String = "AxisLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AxisSignalProvider()) { entry in
            AxisLockScreenView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Axis Signal")
        .description("The single most important thing, right now.")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct AxisHomeWidget: Widget {
    let kind: String = "AxisHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AxisSignalProvider()) { entry in
            AxisHomeWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Axis")
        .description("Your top signal with one-tap actions.")
        .supportedFamilies([.systemMedium])
    }
}
