import SwiftUI

struct Step6Ready: View {
    var onComplete: () -> Void
    @State private var pulseScale: CGFloat = 0.95
    @State private var markVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Breathing Axis mark
            AxisMark(size: 100, color: .axisViolet)
                .scaleEffect(pulseScale)
                .opacity(markVisible ? 1.0 : 0)
                .animation(
                    .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                    value: pulseScale
                )

            Spacer().frame(height: AxisSpacing.xl)

            Text("Axis is watching.")
                .font(.axisSyne(28))
                .foregroundColor(.white)
                .opacity(markVisible ? 1.0 : 0)

            Spacer().frame(height: AxisSpacing.base)

            Text("Your captures are live.\nConnect more to make Axis smarter.")
                .font(.axisBody1)
                .foregroundColor(.axisTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .opacity(markVisible ? 1.0 : 0)

            Spacer()

            // Progress dots
            HStack(spacing: AxisSpacing.sm) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index == 5 ? Color.white : Color.axisVioletBorder)
                        .frame(width: 8, height: 8)
                }
            }

            Spacer().frame(height: AxisSpacing.xl)

            AxisPrimaryButton(title: "Enter Axis") {
                onComplete()
            }
            .padding(.horizontal, AxisSpacing.xxl)
            .padding(.bottom, AxisSpacing.xl)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                markVisible = true
            }
            pulseScale = 1.05
        }
    }
}
