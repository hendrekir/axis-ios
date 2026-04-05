import SwiftUI

struct SignalView: View {
    @State private var signals: [Signal] = []
    @State private var isLoading = true

    var body: some View {
        List {
            ForEach(signals.filter { !$0.isCompleted && !$0.isSnoozed }) { signal in
                SignalRow(signal: signal) {
                    await completeSignal(signal)
                } onSnooze: {
                    await snoozeSignal(signal)
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if isLoading {
                ProgressView()
            }
            if !isLoading && signals.isEmpty {
                ContentUnavailableView(
                    "All clear",
                    systemImage: "checkmark.seal",
                    description: Text("No signals right now. Axis is watching.")
                )
            }
        }
        .navigationTitle("Situation")
        .scrollContentBackground(.hidden)
        .background(Color("AxisBackground"))
        .task { await loadSignals() }
        .refreshable { await loadSignals() }
    }

    private func loadSignals() async {
        do {
            signals = try await APIService.shared.request("/signal")
            isLoading = false
        } catch {
            isLoading = false
        }
    }

    private func completeSignal(_ signal: Signal) async {
        do {
            try await APIService.shared.requestVoid("/signal/\(signal.id)/complete", method: "POST")
            signals.removeAll { $0.id == signal.id }
        } catch { }
    }

    private func snoozeSignal(_ signal: Signal) async {
        do {
            try await APIService.shared.requestVoid("/signal/\(signal.id)/snooze", method: "POST")
            signals.removeAll { $0.id == signal.id }
        } catch { }
    }
}

// MARK: - Signal Row

private struct SignalRow: View {
    let signal: Signal
    let onComplete: () async -> Void
    let onSnooze: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                UrgencyBadge(urgency: signal.urgency)

                Text(signal.category.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(signal.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Text(signal.title)
                .font(.body.bold())

            if let body = signal.body {
                Text(body)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if signal.actionable {
                HStack(spacing: 8) {
                    Button {
                        Task { await onComplete() }
                    } label: {
                        Label("Done", systemImage: "checkmark")
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        Task { await onSnooze() }
                    } label: {
                        Label("Snooze", systemImage: "clock")
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color("AxisCard"), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Urgency Badge

private struct UrgencyBadge: View {
    let urgency: Int

    var color: Color {
        switch urgency {
        case 8...10: .red
        case 6...7: .orange
        case 4...5: .yellow
        default: .gray
        }
    }

    var body: some View {
        Text("\(urgency)")
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .frame(width: 22, height: 22)
            .background(color, in: Circle())
    }
}

#Preview {
    NavigationStack {
        SignalView()
    }
}
