import SwiftUI

struct AxisCard<Content: View>: View {
    var elevated: Bool = false
    var accent: Bool = false
    let content: Content

    init(elevated: Bool = false, accent: Bool = false, @ViewBuilder content: () -> Content) {
        self.elevated = elevated
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        content
            .background(elevated ? Color.axisSurface1 : Color.axisSurface1.opacity(0.6))
            .cornerRadius(AxisRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AxisRadius.lg)
                    .stroke(
                        accent ? Color.axisVioletBorder : Color.axisBorderDefault,
                        lineWidth: 0.5
                    )
            )
    }
}
