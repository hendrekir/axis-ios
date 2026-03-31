import SwiftUI

struct BriefView: View {
    @State private var brief: Brief?
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let brief {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Good morning")
                            .font(.title2.bold())
                        Text(brief.generatedAt, style: .date)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    // Brief messages
                    ForEach(brief.messages) { message in
                        BriefCard(message: message)
                    }

                    // Silent count
                    if brief.silentCount > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.secondary)
                            Text("Axis handled \(brief.silentCount) items silently overnight.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                    }

                    // Sign-off
                    Text("Put the phone down.")
                        .font(.headline)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)
                }
            }
            .padding(.vertical)
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
            if !isLoading && brief == nil {
                ContentUnavailableView(
                    "No brief yet",
                    systemImage: "sunrise",
                    description: Text("Your morning brief will appear here at 6:50 AM.")
                )
            }
        }
        .navigationTitle("Brief")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadBrief() }
        .refreshable { await loadBrief() }
    }

    private func loadBrief() async {
        do {
            brief = try await APIService.shared.request("/brief/today")
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}

// MARK: - Brief Card

private struct BriefCard: View {
    let message: Brief.BriefMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let category = message.category {
                Text(category.uppercased())
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }

            Text(message.content)
                .font(.body)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        BriefView()
    }
}
