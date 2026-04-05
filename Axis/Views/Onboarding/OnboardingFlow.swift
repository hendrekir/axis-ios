import SwiftUI

struct OnboardingFlow: View {
    var onComplete: () -> Void
    @State private var currentStep: Int = 0
    @State private var firstCapture: String = ""

    var body: some View {
        ZStack {
            Color.axisBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Content
                Group {
                    switch currentStep {
                    case 0: Step1Welcome()
                    case 1: Step2FridgeNote(onCapture: { text in
                        firstCapture = text
                        withAnimation(.easeInOut(duration: 0.3)) { currentStep = 2 }
                    })
                    case 2: Step3Confirmation(onAddMore: {
                        withAnimation(.easeInOut(duration: 0.3)) { currentStep = 1 }
                    }, onContinue: {
                        withAnimation(.easeInOut(duration: 0.3)) { currentStep = 3 }
                    })
                    case 3: Step4Privacy()
                    case 4: Step5Connections()
                    case 5: Step6Ready(onComplete: onComplete)
                    default: EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Dots + Continue button (not on capture screen, confirmation, or ready)
                if currentStep != 1 && currentStep != 2 && currentStep < 5 {
                    VStack(spacing: AxisSpacing.xl) {
                        // Progress dots
                        HStack(spacing: AxisSpacing.sm) {
                            ForEach(0..<6, id: \.self) { index in
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
