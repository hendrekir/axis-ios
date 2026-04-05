import SwiftUI

struct OnboardingFlow: View {
    var onComplete: () -> Void
    @State private var currentStep: Int = 0

    var body: some View {
        ZStack {
            Color.axisBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Content
                Group {
                    switch currentStep {
                    case 0: Step1Welcome()
                    case 1: Step2Capture()
                    case 2: Step3Connect()
                    case 3: Step4Permissions()
                    case 4: Step5Ready(onComplete: onComplete)
                    default: EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Dots + Continue button
                if currentStep < 4 {
                    VStack(spacing: AxisSpacing.xl) {
                        // Progress dots
                        HStack(spacing: AxisSpacing.sm) {
                            ForEach(0..<5, id: \.self) { index in
                                Circle()
                                    .fill(index == currentStep ? Color.white : Color.axisVioletBorder)
                                    .frame(width: 8, height: 8)
                            }
                        }

                        // Continue button
                        AxisPrimaryButton(title: currentStep == 0 ? "Get started" : "Continue") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep += 1
                            }
                        }
                    }
                    .padding(.horizontal, AxisSpacing.xxl)
                    .padding(.bottom, AxisSpacing.xl)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
