import SwiftUI

struct Step2FridgeNote: View {
    var onCapture: (String) -> Void
    @State private var text = ""
    @State private var isSaving = false
    @FocusState private var isFocused: Bool

    var canSubmit: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSaving
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 80)

            Text("What have you been\nmeaning to do?")
                .font(.axisSyne(28))
                .foregroundColor(.axisTextPrimary)
                .lineSpacing(6)
                .padding(.horizontal, AxisSpacing.xxl)

            Spacer().frame(height: AxisSpacing.xl)

            // Text input
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("Anything. Call someone, book something, find something, remember something...")
                        .font(.axisBody1)
                        .foregroundColor(.axisTextMuted)
                        .padding(16)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $text)
                    .font(.axisBody1)
                    .foregroundColor(.axisTextPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .focused($isFocused)
            }
            .frame(minHeight: 140)
            .background(Color.axisSurface2)
            .cornerRadius(AxisRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AxisRadius.md)
                    .stroke(isFocused ? Color.axisVioletBorder : Color.axisBorderInput, lineWidth: 0.5)
            )
            .padding(.horizontal, AxisSpacing.xxl)

            Spacer().frame(height: AxisSpacing.base)

            // Voice + Save row
            HStack(spacing: AxisSpacing.sm) {
                // Voice button
                Button {
                    // Voice capture placeholder
                } label: {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.axisViolet)
                        .frame(width: 52, height: 52)
                        .background(Color.axisVioletDim)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                // Save button
                Button {
                    save()
                } label: {
                    HStack(spacing: 8) {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        }
                        Text(isSaving ? "Saving..." : "Catch it")
                    }
                    .font(.axisBody(15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(canSubmit ? Color.axisViolet : Color.axisViolet.opacity(0.4))
                    .cornerRadius(AxisRadius.xl)
                }
                .buttonStyle(.plain)
                .disabled(!canSubmit)
            }
            .padding(.horizontal, AxisSpacing.xxl)

            Spacer()

            // Progress dots
            HStack(spacing: AxisSpacing.sm) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index == 1 ? Color.white : Color.axisVioletBorder)
                        .frame(width: 8, height: 8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, AxisSpacing.xl)
        }
        .onAppear { isFocused = true }
    }

    private func save() {
        let content = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        isSaving = true
        Task {
            do {
                try await APIService.shared.requestVoid(
                    "/capture",
                    method: "POST",
                    body: CaptureRequest(content: content)
                )
            } catch {
                // Still advance — capture saved locally in intent
            }
            isSaving = false
            onCapture(content)
        }
    }
}
