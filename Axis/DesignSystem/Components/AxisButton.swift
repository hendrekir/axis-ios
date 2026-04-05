import SwiftUI

struct AxisPrimaryButton: View {
    let title: String
    let action: () -> Void
    var destructive: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.axisBody(15, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    destructive ? Color.axisRed : Color.axisViolet
                )
                .cornerRadius(AxisRadius.xl)
        }
        .buttonStyle(.plain)
    }
}

struct AxisSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.axisBody(15, weight: .medium))
                .foregroundColor(.axisTextPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.axisSurface2)
                .cornerRadius(AxisRadius.xl)
                .overlay(
                    RoundedRectangle(cornerRadius: AxisRadius.xl)
                        .stroke(Color.axisBorderInput, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}
