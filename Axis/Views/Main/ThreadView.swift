import SwiftUI

struct ThreadView: View {
    @State private var messages: [ThreadMessage] = []
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, AxisSpacing.base)
                    .padding(.top, AxisSpacing.sm)
                    .padding(.bottom, AxisSpacing.base)
                }
                .onChange(of: messages.count) {
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .tint(.axisViolet)
                }
                if !isLoading && messages.isEmpty {
                    ContentUnavailableView(
                        "Axis is watching",
                        systemImage: "eye",
                        description: Text("Messages will appear here.")
                    )
                }
            }

            ThreadInputBar(onSend: { text in
                await sendMessage(text)
            })
            .background(Color.axisSurface1)
            .overlay(
                Divider().background(Color.axisBorderDefault),
                alignment: .top
            )
        }
        .background(Color.axisBackground)
        .navigationTitle("Axis")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadMessages() }
        .refreshable { await loadMessages() }
    }

    private func loadMessages() async {
        do {
            messages = try await APIService.shared.request("/thread/history")
        } catch { }
        isLoading = false
    }

    private func sendMessage(_ text: String) async {
        // Optimistic: add user message immediately
        let optimistic = ThreadMessage(
            id: UUID(),
            role: "user",
            content: text,
            messageType: nil,
            sourceSkill: nil,
            createdAt: Date()
        )
        messages.append(optimistic)

        do {
            let result: ThreadSendResponse = try await APIService.shared.request(
                "/thread",
                method: "POST",
                body: ["content": text]
            )
            messages.append(result.response)
        } catch { }
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: ThreadMessage

    var body: some View {
        if message.isFromAxis {
            axisBubble
        } else {
            userBubble
        }
    }

    private var axisBubble: some View {
        HStack(alignment: .top, spacing: 10) {
            // Axis mark avatar
            ZStack {
                Circle()
                    .fill(Color.axisVioletDim)
                    .frame(width: 28, height: 28)
                AxisMark(size: 16, color: .axisViolet)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(message.content)
                    .font(.axisBody1)
                    .foregroundColor(.axisTextPrimary)
                    .lineSpacing(4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            Color.axisSurface2
                            Color.axisViolet.opacity(0.05)
                        }
                    )
                    .clipShape(BubbleShape(corners: [.topLeft], smallRadius: 4, largeRadius: 18))
                    .overlay(
                        BubbleShape(corners: [.topLeft], smallRadius: 4, largeRadius: 18)
                            .stroke(Color.axisViolet.opacity(0.15), lineWidth: 0.5)
                    )
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(Color.axisViolet)
                            .frame(width: 2)
                    }

                // Action buttons
                if message.isActionable {
                    ThreadActionButtonRow(message: message)
                }

                // Timestamp
                Text(message.createdAt, style: .relative)
                    .font(.axisMono(10))
                    .foregroundColor(.axisTextMuted)
                    .padding(.leading, 4)
            }

            Spacer(minLength: 60)
        }
        .padding(.vertical, 4)
    }

    private var userBubble: some View {
        HStack(alignment: .top, spacing: 10) {
            Spacer(minLength: 60)

            VStack(alignment: .trailing, spacing: 4) {
                Text(message.content)
                    .font(.axisBody1)
                    .foregroundColor(.white)
                    .lineSpacing(4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.axisViolet)
                    .clipShape(BubbleShape(corners: [.bottomRight], smallRadius: 4, largeRadius: 18))

                Text(message.createdAt, style: .relative)
                    .font(.axisMono(10))
                    .foregroundColor(.axisTextMuted)
                    .padding(.trailing, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Bubble Shape

private struct BubbleShape: Shape {
    /// Which corners get the small radius (the "join" side)
    let corners: UIRectCorner
    let smallRadius: CGFloat
    let largeRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let tl = corners.contains(.topLeft) ? smallRadius : largeRadius
        let tr = corners.contains(.topRight) ? smallRadius : largeRadius
        let bl = corners.contains(.bottomLeft) ? smallRadius : largeRadius
        let br = corners.contains(.bottomRight) ? smallRadius : largeRadius

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                     tangent2End: CGPoint(x: rect.maxX, y: rect.minY + tr),
                     radius: tr)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
                     tangent2End: CGPoint(x: rect.maxX - br, y: rect.maxY),
                     radius: br)
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
                     tangent2End: CGPoint(x: rect.minX, y: rect.maxY - bl),
                     radius: bl)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                     tangent2End: CGPoint(x: rect.minX + tl, y: rect.minY),
                     radius: tl)
        path.closeSubpath()
        return path
    }
}

// MARK: - Action Button Row

private struct ThreadActionButtonRow: View {
    let message: ThreadMessage

    var body: some View {
        HStack(spacing: AxisSpacing.sm) {
            switch message.actionType {
            case .sendReply:
                actionButton("Send", primary: true)
                actionButton("Edit", primary: false)
                actionButton("Later", primary: false)
            case .markDone:
                actionButton("Done", primary: true)
                actionButton("Snooze", primary: false)
            default:
                EmptyView()
            }
        }
    }

    private func actionButton(_ label: String, primary: Bool) -> some View {
        Button(label) { }
            .font(.axisBody(13, weight: .medium))
            .foregroundColor(primary ? .white : .axisTextSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(primary ? Color.axisViolet : Color.axisSurface2)
            .cornerRadius(AxisRadius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: AxisRadius.pill)
                    .stroke(primary ? Color.clear : Color.axisBorderDefault, lineWidth: 0.5)
            )
            .buttonStyle(.plain)
    }
}

// MARK: - Thread Input Bar

private struct ThreadInputBar: View {
    var onSend: (String) async -> Void
    @State private var inputText: String = ""
    @State private var isRecording: Bool = false
    @State private var isSending: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Text input
            ZStack(alignment: .leading) {
                if inputText.isEmpty {
                    Text("Capture anything...")
                        .font(.axisBody1)
                        .foregroundColor(.axisTextMuted)
                        .padding(.horizontal, 14)
                }
                TextField("", text: $inputText, axis: .vertical)
                    .font(.axisBody1)
                    .foregroundColor(.axisTextPrimary)
                    .lineLimit(1...6)
                    .focused($isFocused)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
            }
            .background(Color.axisSurface2)
            .cornerRadius(22)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        isFocused ? Color.axisVioletBorder : Color.axisBorderInput,
                        lineWidth: 0.5
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)

            // Mic / Send toggle
            if inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button(action: { isRecording.toggle() }) {
                    Image(systemName: isRecording ? "waveform" : "mic.fill")
                        .font(.system(size: 18))
                        .foregroundColor(isRecording ? .axisRed : .axisViolet)
                        .frame(width: 44, height: 44)
                        .background(isRecording ? Color.axisRedDim : Color.axisVioletDim)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            } else {
                Button(action: { send() }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.axisViolet)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(isSending)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, AxisSpacing.base)
        .padding(.vertical, 10)
        .animation(.easeInOut(duration: 0.15), value: inputText.isEmpty)
    }

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        isFocused = false
        isSending = true
        Task {
            await onSend(text)
            isSending = false
        }
    }
}
