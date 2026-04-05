import SwiftUI

struct Step5Ready: View {
    var onComplete: () -> Void
    @State private var pulseScale: CGFloat = 0.95

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Breathing Axis mark
            AxisMark(size: 100, color: .axisViolet)
                .scaleEffect(pulseScale)
                .animation(
                    .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                    value: pulseScale
                )

            Spacer().frame(height: AxisSpacing.xl)

            Text("You're set up.")
                .font(.axisSyne(32))
                .foregroundColor(.white)

            Spacer().frame(height: AxisSpacing.base)

            Text("Axis is watching.\nEvery morning at 6:50,\nyour brief arrives.")
                .font(.axisBody1)
                .foregroundColor(.axisTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)

            Spacer()

            // Progress dots
            HStack(spacing: AxisSpacing.sm) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index == 4 ? Color.white : Color.axisVioletBorder)
                        .frame(width: 8, height: 8)
                }
            }

            Spacer().frame(height: AxisSpacing.xl)

            AxisPrimaryButton(title: "Let's go") {
                onComplete()
            }
            .padding(.horizontal, AxisSpacing.xxl)
            .padding(.bottom, AxisSpacing.xl)
        }
        .onAppear {
            pulseScale = 1.05
        }
    }
}
