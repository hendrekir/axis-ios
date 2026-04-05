import SwiftUI

struct Step2Capture: View {
    @State private var bubbleVisible = false
    @State private var replyVisible = false

    var body: some View {
        VStack(spacing: 0) {
            // Top half: animated capture demo
            VStack(spacing: AxisSpacing.base) {
                Spacer()

                // User speech bubble
                Text("Hey Siri, tell Axis: the membrane on Level 2 is failing")
                    .font(.axisBody1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.axisViolet)
                    .cornerRadius(18)
                    .opacity(bubbleVisible ? 1 : 0)
                    .offset(y: bubbleVisible ? 0 : 20)

                // Axis reply
                HStack(alignment: .top, spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.axisVioletDim)
                            .frame(width: 24, height: 24)
                        AxisMark(size: 12, color: .axisViolet)
                    }
                    Text("Added to site tasks. Supplier alert queued for Thursday.")
                        .font(.axisBody2)
                        .foregroundColor(.axisTextPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.axisSurface1)
                        .cornerRadius(18)
                }
                .opacity(replyVisible ? 1 : 0)
                .offset(y: replyVisible ? 0 : 20)

                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, AxisSpacing.xxl)

            // Bottom half: text
            VStack(alignment: .leading, spacing: AxisSpacing.base) {
                Text("Capture anything.\nFrom anywhere.")
                    .font(.axisSyne(24))
                    .foregroundColor(.white)

                Text("Voice. Text. Photos. Shared from any app. Axis captures and structures everything so you don't have to think about it.")
                    .font(.axisBody1)
                    .foregroundColor(.axisTextSecondary)
                    .lineSpacing(6)
            }
            .padding(.horizontal, AxisSpacing.xxl)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                bubbleVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(1.0)) {
                replyVisible = true
            }
        }
    }
}
