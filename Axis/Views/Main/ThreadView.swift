import SwiftUI

struct ThreadView: View {
    @State private var messages: [ThreadMessage] = []
    @State private var inputText = ""
    @State private var isLoading = true
    @State private var isSending = false

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: messages.count) {
                    if let last = messages.last {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                }
                if !isLoading && messages.isEmpty {
                    ContentUnavailableView(
                        "No messages yet",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Axis will message you here when something needs your attention.")
                    )
                }
            }

            Divider()

            // Input bar
            HStack(spacing: 12) {
                TextField("Message Axis...", text: $inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color("AxisCard"), in: Capsule())

                if inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button {
                        // TODO: voice input
                    } label: {
                        Image(systemName: "mic.fill")
                            .font(.title3)
                            .foregroundStyle(Color.accentColor)
                    }
                } else {
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    }
                    .disabled(isSending)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.bar)
        }
        .navigationTitle("Axis")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("AxisBackground"))
        .task { await loadMessages() }
        .refreshable { await loadMessages() }
    }

    private func loadMessages() async {
        do {
            messages = try await APIService.shared.request("/thread")
            isLoading = false
        } catch {
            isLoading = false
        }
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        isSending = true

        // Show user's message immediately
        let userMessage = ThreadMessage(
            id: UUID(),
            userId: UUID(),
            sender: .user,
            content: text,
            contentType: .text,
            actionType: nil,
            actionPayload: nil,
            urgency: nil,
            surface: nil,
            readAt: nil,
            createdAt: Date()
        )
        messages.append(userMessage)

        Task {
            do {
                let response: ThreadMessage = try await APIService.shared.request(
                    "/thread",
                    method: "POST",
                    body: ["message": text]
                )
                messages.append(response)
            } catch {
                // Remove optimistic message and restore input on failure
                messages.removeAll { $0.id == userMessage.id }
                inputText = text
            }
            isSending = false
        }
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: ThreadMessage

    var body: some View {
        HStack {
            if !message.isFromAxis { Spacer(minLength: 60) }

            VStack(alignment: message.isFromAxis ? .leading : .trailing, spacing: 6) {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(message.isFromAxis ? Color.primary : Color.white)

                if message.isActionable {
                    ActionButtons(message: message)
                }

                Text(message.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(message.isFromAxis ? Color.secondary : Color.white.opacity(0.7))
            }
            .padding(12)
            .background(
                message.isFromAxis
                    ? Color("AxisCard")
                    : Color.accentColor,
                in: RoundedRectangle(cornerRadius: 16)
            )

            if message.isFromAxis { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Action Buttons

private struct ActionButtons: View {
    let message: ThreadMessage

    var body: some View {
        HStack(spacing: 8) {
            switch message.actionType {
            case .sendReply:
                ActionChip(label: "Send", icon: "paperplane.fill") { }
                ActionChip(label: "Edit", icon: "pencil") { }
                ActionChip(label: "Later", icon: "clock") { }
            case .markDone:
                ActionChip(label: "Done", icon: "checkmark") { }
                ActionChip(label: "Snooze", icon: "clock") { }
            default:
                EmptyView()
            }
        }
    }
}

private struct ActionChip: View {
    let label: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ThreadView()
    }
}
