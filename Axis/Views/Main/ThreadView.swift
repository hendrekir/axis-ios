import SwiftUI

struct ThreadView: View {
    @State private var messages: [ThreadMessage] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(messages) { message in
                    MessageCard(message: message)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .tint(Color.accentColor)
            }
            if !isLoading && messages.isEmpty {
                ContentUnavailableView(
                    "Axis is watching",
                    systemImage: "eye",
                    description: Text("Messages will appear here.")
                )
            }
        }
        .navigationTitle("Axis")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.axisBackground)
        .task { await loadMessages() }
        .refreshable { await loadMessages() }
    }

    private func loadMessages() async {
        do {
            messages = try await APIService.shared.request("/thread")
        } catch { }
        isLoading = false
    }
}

// MARK: - Message Card

private struct MessageCard: View {
    let message: ThreadMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Category + timestamp
            HStack {
                Text(message.contentType.rawValue.replacingOccurrences(of: "_", with: " ").uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                Spacer()

                Text(message.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            // Content
            Text(message.content)
                .font(.body)

            // Action buttons
            if message.isActionable {
                ActionButtons(message: message)
            }
        }
        .padding(16)
        .background(Color.axisSurface1, in: RoundedRectangle(cornerRadius: 16))
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
                .background(Color.accentColor.opacity(0.15), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ThreadView()
    }
}
