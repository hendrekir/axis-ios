import SwiftUI

struct AxisTextField: View {
    let placeholder: String
    @Binding var text: String
    var multiline: Bool = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.axisBody1)
                    .foregroundColor(.axisTextMuted)
                    .padding(.horizontal, AxisSpacing.base)
                    .padding(.top, 14)
            }
            if multiline {
                TextEditor(text: $text)
                    .font(.axisBody1)
                    .foregroundColor(.axisTextPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, AxisSpacing.md)
                    .padding(.vertical, AxisSpacing.sm)
            } else {
                TextField("", text: $text)
                    .font(.axisBody1)
                    .foregroundColor(.axisTextPrimary)
                    .padding(.horizontal, AxisSpacing.base)
                    .frame(height: 52)
            }
        }
        .background(Color.axisSurface2)
        .cornerRadius(AxisRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AxisRadius.md)
                .stroke(Color.axisBorderInput, lineWidth: 0.5)
        )
    }
}
