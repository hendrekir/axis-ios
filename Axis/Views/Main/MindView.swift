import SwiftUI

enum MindTab: String, CaseIterable, Identifiable {
    case map = "Map"
    case skills = "Skills"
    case journal = "Journal"

    var id: String { rawValue }
    var label: String { rawValue }
}

struct MindView: View {
    @State private var selectedTab: MindTab = .journal

    var body: some View {
        VStack(spacing: 0) {
            // Segmented control
            MindSegmentedControl(selected: $selectedTab)
                .padding(.horizontal, AxisSpacing.base)
                .padding(.top, AxisSpacing.sm)
                .padding(.bottom, AxisSpacing.md)

            // Content
            switch selectedTab {
            case .map:     MindMapPlaceholder()
            case .skills:  SkillTreePlaceholder()
            case .journal: JournalView()
            }
        }
        .background(Color.axisBackground)
        .navigationTitle("Mind")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Segmented Control

struct MindSegmentedControl: View {
    @Binding var selected: MindTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MindTab.allCases) { tab in
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selected = tab } }) {
                    Text(tab.label)
                        .font(.axisBody(13, weight: selected == tab ? .medium : .regular))
                        .foregroundColor(selected == tab ? .axisTextPrimary : .axisTextMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            selected == tab ? Color.axisSurface2 : Color.clear
                        )
                        .cornerRadius(AxisRadius.md)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color.axisSurface1)
        .cornerRadius(AxisRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: AxisRadius.lg)
                .stroke(Color.axisBorderDefault, lineWidth: 0.5)
        )
    }
}

// MARK: - Journal View

struct JournalView: View {
    @State private var journalDraft: String = ""
    @State private var hasAnswered = false
    @State private var isSaving = false
    @State private var pastEntries: [JournalEntryData] = []
    @FocusState private var isFocused: Bool

    private var todaysQuestion: String {
        let dayOfWeek = Calendar.current.component(.weekday, from: Date())
        return Self.questions[(dayOfWeek - 1) % Self.questions.count]
    }

    private var dayName: String {
        Date().formatted(.dateTime.weekday(.wide))
    }

    private static let questions = [
        "What does next week need to feel like?",                              // Sunday
        "What's the one thing that would make this week feel like a success?", // Monday
        "Who do you need to reach out to that you've been putting off?",       // Tuesday
        "What's working right now that you should do more of?",                // Wednesday
        "What decision have you been avoiding? What's actually stopping you?", // Thursday
        "What did you learn this week — about work, people, yourself?",        // Friday
        "What would you do tomorrow if it wasn't about being productive?",     // Saturday
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AxisSpacing.base) {
                // Today's question card
                AxisCard(elevated: true, accent: true) {
                    VStack(alignment: .leading, spacing: AxisSpacing.md) {
                        HStack {
                            AxisTag(text: "Today · \(dayName)", color: .axisViolet)
                            Spacer()
                        }

                        Text(todaysQuestion)
                            .font(.axisH1)
                            .foregroundColor(.axisTextPrimary)
                            .lineSpacing(3)

                        if hasAnswered {
                            Text(journalDraft)
                                .font(.axisBody1)
                                .foregroundColor(.axisTextSecondary)
                                .lineSpacing(4)
                                .padding(AxisSpacing.md)
                                .background(Color.axisSurface2)
                                .cornerRadius(AxisRadius.md)
                        } else {
                            AxisTextField(
                                placeholder: "What's on your mind...",
                                text: $journalDraft,
                                multiline: true
                            )
                            .frame(minHeight: 100)
                            .focused($isFocused)

                            Button(action: { submitJournalEntry() }) {
                                Text("Save")
                                    .font(.axisBody(14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, AxisSpacing.xl)
                                    .padding(.vertical, 10)
                                    .background(Color.axisViolet)
                                    .cornerRadius(AxisRadius.pill)
                            }
                            .buttonStyle(.plain)
                            .disabled(journalDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                        }
                    }
                    .padding(AxisSpacing.base)
                }

                // Past entries
                if !pastEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("This week")
                            .font(.axisMono(11))
                            .foregroundColor(.axisTextMuted)
                            .textCase(.uppercase)
                            .kerning(1.5)
                            .padding(.horizontal, 4)

                        ForEach(pastEntries) { entry in
                            JournalEntryRow(entry: entry)
                        }
                    }
                }
            }
            .padding(.horizontal, AxisSpacing.base)
            .padding(.top, AxisSpacing.xs)
        }
        .onTapGesture { hideKeyboard() }
        .task { await loadEntries() }
    }

    private func submitJournalEntry() {
        let text = journalDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        isSaving = true
        isFocused = false

        Task {
            do {
                let _: BrainDumpResponse = try await APIService.shared.request(
                    "/brain-dump",
                    method: "POST",
                    body: ["content": text]
                )
            } catch { }

            isSaving = false
            withAnimation { hasAnswered = true }
        }
    }

    private func loadEntries() async {
        // Past entries would come from a journal endpoint
        // For now, this is a placeholder
    }
}

// MARK: - Journal Entry Data

struct JournalEntryData: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let date: Date
}

// MARK: - Journal Entry Row

private struct JournalEntryRow: View {
    let entry: JournalEntryData

    var body: some View {
        AxisCard {
            HStack(spacing: AxisSpacing.md) {
                VStack(alignment: .leading, spacing: AxisSpacing.xs) {
                    Text(entry.question)
                        .font(.axisBody2)
                        .foregroundColor(.axisTextMuted)
                        .lineLimit(1)
                    Text(entry.answer)
                        .font(.axisBody1)
                        .foregroundColor(.axisTextPrimary)
                        .lineLimit(2)
                }

                Spacer()

                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.axisMono(10))
                    .foregroundColor(.axisTextMuted)
            }
            .padding(14)
        }
    }
}

// MARK: - Placeholders for Map and Skill Tree

private struct MindMapPlaceholder: View {
    var body: some View {
        ContentUnavailableView(
            "Mind Map",
            systemImage: "circle.grid.cross",
            description: Text("Your mind map will appear here as Axis learns about you.")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct SkillTreePlaceholder: View {
    var body: some View {
        ContentUnavailableView(
            "Skill Tree",
            systemImage: "cpu",
            description: Text("Connected skills and their status will appear here.")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
