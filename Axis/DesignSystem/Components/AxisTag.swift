import SwiftUI

struct AxisTag: View {
    let text: String
    var color: Color = .axisViolet

    var body: some View {
        Text(text.uppercased())
            .font(.axisMicro)
            .foregroundColor(color)
            .padding(.horizontal, AxisSpacing.sm)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .cornerRadius(AxisRadius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: AxisRadius.pill)
                    .stroke(color.opacity(0.2), lineWidth: 0.5)
            )
    }
}
