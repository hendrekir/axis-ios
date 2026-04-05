import SwiftUI

struct ApprenticeView: View {
    @State private var insights: [ApprenticeInsight] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Apprentice")
                        .font(.title2.bold())
                    Text("What Axis has learned about you this week.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                if insights.isEmpty && !isLoading {
                    ContentUnavailableView(
                        "Learning in progress",
                        systemImage: "brain",
                        description: Text("Axis needs a few days of data before insights appear.")
                    )
                    .padding(.top, 40)
                }

                ForEach(insights) { insight in
                    InsightCard(insight: insight)
                }
            }
            .padding(.vertical)
        }
        .overlay { if isLoading { ProgressView() } }
        .navigationTitle("Apprentice")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.axisBackground)
        .task { await loadInsights() }
        .refreshable { await loadInsights() }
    }

    private func loadInsights() async {
        do {
            insights = try await APIService.shared.request("/apprentice/insights")
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}

// MARK: - Insight Card

private struct InsightCard: View {
    let insight: ApprenticeInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(insight.category.uppercased())
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)

                Spacer()

                ConfidencePill(confidence: insight.confidence)
            }

            Text(insight.title)
                .font(.body.bold())

            Text(insight.body)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color.axisSurface1, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Confidence Pill

private struct ConfidencePill: View {
    let confidence: Double

    var label: String {
        switch confidence {
        case 0.8...: "High"
        case 0.5...: "Medium"
        default: "Low"
        }
    }

    var color: Color {
        switch confidence {
        case 0.8...: .green
        case 0.5...: .orange
        default: .gray
        }
    }

    var body: some View {
        Text(label)
            .font(.caption2.bold())
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15), in: Capsule())
    }
}

#Preview {
    NavigationStack {
        ApprenticeView()
    }
}
