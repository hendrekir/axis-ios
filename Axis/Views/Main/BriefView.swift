import SwiftUI

struct BriefView: View {
    @State private var brief: Brief?
    @State private var isLoading = true
    @State private var loadFailed = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let brief {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.title2.bold())
                        Text(brief.generatedAt, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    // Morning summary
                    ForEach(brief.messages) { message in
                        BriefCard(message: message)
                    }

                    // Calendar events
                    if let events = brief.calendarEvents, !events.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TODAY'S CALENDAR")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)

                            ForEach(events) { event in
                                CalendarEventRow(event: event)
                            }
                        }
                    }

                    // Gmail connection status
                    GmailStatusRow(isConnected: brief.gmailConnected ?? false)
                        .padding(.horizontal)

                    // Silent count
                    if brief.silentCount > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.secondary)
                            Text("Axis handled \(brief.silentCount) items silently overnight.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                    }

                    // Sign-off
                    Text("Put the phone down.")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)
                }
            }
            .padding(.vertical)
        }
        .overlay {
            if isLoading {
                BriefLoadingView()
            }
            if !isLoading && brief == nil {
                BriefEmptyView(loadFailed: loadFailed)
            }
        }
        .navigationTitle("Brief")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.axisBackground)
        .task { await loadBrief() }
        .refreshable { await loadBrief() }
    }

    private func loadBrief() async {
        do {
            brief = try await APIService.shared.request("/brief/today")
            loadFailed = false
        } catch {
            loadFailed = true
        }
        isLoading = false
    }
}

// MARK: - Brief Card

private struct BriefCard: View {
    let message: Brief.BriefMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let category = message.category {
                Text(category.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            Text(message.content)
                .font(.body)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.axisSurface1, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Calendar Event Row

private struct CalendarEventRow: View {
    let event: Brief.CalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.accentColor)
                .frame(width: 4, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.body)

                HStack(spacing: 4) {
                    Text(event.startTime, style: .time)
                    if let end = event.endTime {
                        Text("–")
                        Text(end, style: .time)
                    }
                    if let location = event.location {
                        Text("· \(location)")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Gmail Status Row

private struct GmailStatusRow: View {
    let isConnected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "envelope.fill")
                .foregroundStyle(isConnected ? .green : .secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Gmail")
                    .font(.body)
                Text(isConnected ? "Connected — inbox is being read" : "Not connected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            } else {
                Text("Connect")
                    .font(.caption.bold())
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(12)
        .background(Color.axisSurface1, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Loading View

private struct BriefLoadingView: View {
    @State private var opacity: Double = 0.4

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sunrise.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
                .opacity(opacity)

            Text("Your brief is loading...")
                .font(.body)
                .foregroundStyle(.secondary)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}

// MARK: - Empty View

private struct BriefEmptyView: View {
    let loadFailed: Bool

    var body: some View {
        ContentUnavailableView(
            loadFailed ? "Couldn't load brief" : "No brief yet",
            systemImage: loadFailed ? "exclamationmark.triangle" : "sunrise",
            description: Text(loadFailed
                ? "Pull down to try again."
                : "Your morning brief will appear here at 6:50 AM.")
        )
    }
}

#Preview {
    NavigationStack {
        BriefView()
    }
}
