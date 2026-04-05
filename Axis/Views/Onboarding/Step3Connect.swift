import SwiftUI

struct Step3Confirmation: View {
    var onAddMore: () -> Void
    var onContinue: () -> Void
    @State private var cardVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Confirmation card
            VStack(spacing: AxisSpacing.xl) {
                // Checkmark
                ZStack {
                    Circle()
                        .fill(Color.axisGreenDim)
                        .frame(width: 64, height: 64)
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.axisGreen)
                }
                .scaleEffect(cardVisible ? 1.0 : 0.6)
                .opacity(cardVisible ? 1.0 : 0)

                Text("Axis caught that.")
                    .font(.axisSyne(24))
                    .foregroundColor(.axisTextPrimary)
                    .opacity(cardVisible ? 1.0 : 0)

                Text("It'll surface it at the right moment — not a fixed reminder you'll dismiss, the actual right time based on your day.")
                    .font(.axisBody1)
                    .foregroundColor(.axisTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, AxisSpacing.base)
                    .opacity(cardVisible ? 1.0 : 0)
            }

            Spacer()

            // Buttons
            VStack(spacing: AxisSpacing.sm) {
                // Progress dots
                HStack(spacing: AxisSpacing.sm) {
                    ForEach(0..<6, id: \.self) { index in
                        Circle()
                            .fill(index == 2 ? Color.white : Color.axisVioletBorder)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, AxisSpacing.sm)

                AxisSecondaryButton(title: "Add more") {
                    onAddMore()
                }

                AxisPrimaryButton(title: "Continue") {
                    onContinue()
                }
            }
            .padding(.horizontal, AxisSpacing.xxl)
            .padding(.bottom, AxisSpacing.xl)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                cardVisible = true
            }
        }
    }
}
