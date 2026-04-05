import SwiftUI

struct SkillsView: View {
    @State private var skills: [Skill] = []
    @State private var isLoading = true

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(skills) { skill in
                    SkillCard(skill: skill)
                }
            }
            .padding(16)
        }
        .overlay {
            if isLoading { ProgressView() }
        }
        .navigationTitle("Skills")
        .scrollContentBackground(.hidden)
        .background(Color.axisBackground)
        .task { await loadSkills() }
        .refreshable { await loadSkills() }
    }

    private func loadSkills() async {
        do {
            skills = try await APIService.shared.request("/skills")
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}

// MARK: - Skill Card

private struct SkillCard: View {
    let skill: Skill

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: skill.icon)
                .font(.title)
                .foregroundStyle(skill.isConnected ? Color.accentColor : Color.secondary)
                .frame(width: 48, height: 48)
                .background(
                    skill.isConnected
                        ? Color.accentColor.opacity(0.12)
                        : Color(.systemGray5),
                    in: RoundedRectangle(cornerRadius: 12)
                )

            VStack(spacing: 4) {
                Text(skill.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                Text(skill.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }

            if skill.requiresOAuth && !skill.isConnected {
                Text("Connect")
                    .font(.caption.bold())
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.12), in: Capsule())
            } else if skill.isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.axisSurface1, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        SkillsView()
    }
}
