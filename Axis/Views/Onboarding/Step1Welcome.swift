import SwiftUI

struct Step1Welcome: View {
    @State private var markVisible = false
    @State private var wordmarkVisible = false
    @State private var taglineVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 84)

            // Axis Mark
            AxisMark(size: 80, color: .axisViolet)
                .scaleEffect(markVisible ? 1.0 : 0.8)
                .opacity(markVisible ? 1.0 : 0)

            Spacer().frame(height: AxisSpacing.base)

            // Wordmark
            Text("AXIS")
                .font(.axisSyne(40))
                .foregroundColor(.axisTextPrimary)
                .tracking(-2)
                .opacity(wordmarkVisible ? 1.0 : 0)

            // Tagline
            Text("EXTEND THE MIND")
                .font(.axisMono(10))
                .foregroundColor(.axisViolet.opacity(0.35))
                .kerning(3.5)
                .opacity(wordmarkVisible ? 1.0 : 0)

            Spacer().frame(height: AxisSpacing.section)

            // Hero text
            Text("AI is extending\nwhat's possible.\nAxis extends you.")
                .font(.axisBody(20))
                .foregroundColor(.axisTextPrimary.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .opacity(taglineVisible ? 1.0 : 0)

            Spacer()
        }
        .frame(maxWidth: 320)
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                markVisible = true
            }
            withAnimation(.easeOut(duration: 0.2).delay(0.7)) {
                wordmarkVisible = true
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.9)) {
                taglineVisible = true
            }
        }
    }
}
