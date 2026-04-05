import SwiftUI

struct BriefView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Segmented control
            Picker("", selection: $selectedTab) {
                Text("Today").tag(0)
                Text("World").tag(1)
                Text("Learn").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, AxisSpacing.base)
            .padding(.vertical, AxisSpacing.sm)

            switch selectedTab {
            case 0:  BriefTodayView()
            case 1:  BriefWorldView()
            case 2:  BriefLearnView()
            default: BriefTodayView()
            }
        }
        .background(Color.axisBackground)
        .navigationTitle("Brief")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Today

private struct BriefTodayView: View {
    @State private var brief: Brief?
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var isPlaying = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AxisSpacing.base) {
                // Date + mode
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Date(), style: .date)
                            .font(.axisSyne(14))
                            .foregroundColor(.axisTextPrimary)
                    }
                    Spacer()
                }
                .padding(.horizontal, AxisSpacing.base)

                if let brief {
                    // Play brief button
                    Button {
                        isPlaying.toggle()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            Text(isPlaying ? "Stop" : "Play morning brief")
                        }
                        .font(.axisBody(14, weight: .medium))
                        .foregroundColor(.axisViolet)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.axisVioletDim)
                        .cornerRadius(AxisRadius.pill)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AxisSpacing.base)

                    // Brief messages
                    ForEach(brief.messages) { message in
                        AxisCard {
                            VStack(alignment: .leading, spacing: 6) {
                                if let category = message.category {
                                    Text(category.uppercased())
                                        .font(.axisMono(9))
                                        .foregroundColor(.axisTextMuted)
                                        .kerning(1.5)
                                }
                                Text(message.content)
                                    .font(.axisBody1)
                                    .foregroundColor(.axisTextPrimary)
                                    .lineSpacing(5)
                            }
                            .padding(14)
                        }
                        .padding(.horizontal, AxisSpacing.base)
                    }

                    // Calendar events
                    if let events = brief.calendarEvents, !events.isEmpty {
                        VStack(alignment: .leading, spacing: AxisSpacing.sm) {
                            Text("TODAY'S CALENDAR")
                                .font(.axisMono(9))
                                .foregroundColor(.axisTextMuted)
                                .kerning(1.5)
                                .padding(.horizontal, AxisSpacing.base)

                            ForEach(events) { event in
                                HStack(spacing: 12) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.axisViolet)
                                        .frame(width: 4, height: 40)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(event.title)
                                            .font(.axisH2)
                                            .foregroundColor(.axisTextPrimary)
                                        HStack(spacing: 4) {
                                            Text(event.startTime, style: .time)
                                            if let end = event.endTime {
                                                Text("-")
                                                Text(end, style: .time)
                                            }
                                            if let loc = event.location {
                                                Text("· \(loc)")
                                            }
                                        }
                                        .font(.axisMono(10))
                                        .foregroundColor(.axisTextMuted)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, AxisSpacing.base)
                            }
                        }
                    }

                    // Sign-off
                    Text("Your move.")
                        .font(Font.custom("InstrumentSans-Regular", size: 14).italic())
                        .foregroundColor(.axisTextMuted)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, AxisSpacing.sm)

                    // Silent count
                    if brief.silentCount > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "eye.slash")
                                .font(.system(size: 11))
                                .foregroundColor(.axisViolet.opacity(0.5))
                            Text("Axis handled \(brief.silentCount) other items quietly")
                                .font(.axisMono(10))
                                .foregroundColor(.axisTextMuted)
                        }
                        .padding(.horizontal, AxisSpacing.base)
                    }
                }
            }
            .padding(.top, AxisSpacing.sm)
            .padding(.bottom, AxisSpacing.xl)
        }
        .overlay {
            if isLoading {
                BriefTodayLoadingView()
            }
            if !isLoading && brief == nil {
                ContentUnavailableView(
                    loadFailed ? "Couldn't load brief" : "No brief yet",
                    systemImage: loadFailed ? "exclamationmark.triangle" : "sunrise",
                    description: Text(loadFailed
                        ? "Pull down to try again."
                        : "Your morning brief will appear here at 6:50 AM.")
                )
            }
        }
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

private struct BriefTodayLoadingView: View {
    @State private var opacity: Double = 0.4

    var body: some View {
        VStack(spacing: AxisSpacing.base) {
            Image(systemName: "sunrise.fill")
                .font(.title2)
                .foregroundColor(.axisViolet)
                .opacity(opacity)
            Text("Loading brief...")
                .font(.axisBody2)
                .foregroundColor(.axisTextSecondary)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}

// MARK: - World

private struct BriefWorldView: View {
    private let stories: [WorldStory] = [
        WorldStory(tag: "Conflict", tagColor: .axisRed, headline: "Iran situation escalates",
                   summary: "Tensions rise in the Middle East as diplomatic talks stall. Key allies are reassessing their positions.",
                   source: "Perplexity · 2h ago"),
        WorldStory(tag: "Local", tagColor: .axisAmber, headline: "Brisbane fuel prices spike",
                   summary: "Unleaded hits $2.18/L this week, highest since January. Costco still cheapest at $2.04.",
                   source: "Perplexity · 4h ago"),
        WorldStory(tag: "Tech", tagColor: .axisViolet, headline: "AI agents reshape workflows",
                   summary: "New research shows 40% of knowledge workers now use AI assistants daily, up from 12% last year.",
                   source: "Perplexity · 6h ago"),
        WorldStory(tag: "Markets", tagColor: .axisGreen, headline: "Economy holds steady",
                   summary: "RBA holds rate at 4.1%. Analysts expect first cut in Q3. ASX flat on the news.",
                   source: "Perplexity · 8h ago"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AxisSpacing.base) {
                ForEach(stories) { story in
                    AxisCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                AxisTag(text: story.tag, color: story.tagColor)
                                Spacer()
                            }
                            Text(story.headline)
                                .font(.axisH1)
                                .foregroundColor(.axisTextPrimary)
                                .lineSpacing(2)
                            Text(story.summary)
                                .font(.axisBody2)
                                .foregroundColor(.axisTextSecondary)
                                .lineSpacing(3)
                            Text(story.source)
                                .font(.axisMono(10))
                                .foregroundColor(.axisTextMuted)
                        }
                        .padding(14)
                    }
                    .padding(.horizontal, AxisSpacing.base)
                }

                // Footer
                Text("World intelligence is personalised as Axis learns more about you.")
                    .font(.axisBody2)
                    .foregroundColor(.axisTextMuted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, AxisSpacing.xl)
                    .padding(.top, AxisSpacing.sm)
            }
            .padding(.top, AxisSpacing.sm)
            .padding(.bottom, AxisSpacing.xl)
        }
    }
}

private struct WorldStory: Identifiable {
    let id = UUID()
    let tag: String
    let tagColor: Color
    let headline: String
    let summary: String
    let source: String
}

// MARK: - Learn

private struct BriefLearnView: View {
    @State private var lessonIndex = 0

    private let lessons: [Lesson] = [
        Lesson(category: "Financial literacy", title: "Compound interest: the eighth wonder",
               content: "Einstein supposedly called compound interest the eighth wonder of the world. At 7% annual return, your money doubles every 10 years. Start investing at 25 instead of 35, and you'll have roughly twice as much at 65 — not because you saved more, but because time did the work.",
               source: "The Psychology of Money, Morgan Housel"),
        Lesson(category: "Business", title: "The 80/20 rule in client revenue",
               content: "Most businesses find that 20% of clients generate 80% of revenue. The insight isn't to fire the other 80% — it's to understand what makes the top 20% different and build your acquisition around that profile. Track which clients refer, which expand, and which drain resources.",
               source: "Built to Sell, John Warrillow"),
        Lesson(category: "Psychology", title: "Decision fatigue is real",
               content: "Judges grant parole at 65% rate after meals but near 0% just before. Your willpower depletes like a battery. Front-load important decisions to mornings. Automate or eliminate trivial choices. This is why Steve Jobs wore the same outfit — one less decision.",
               source: "Thinking, Fast and Slow, Daniel Kahneman"),
        Lesson(category: "History", title: "Why civilisations collapse",
               content: "Joseph Tainter's research shows civilisations don't fall from external attack — they collapse from complexity. Each problem solved adds bureaucratic layers until maintaining the system costs more than it produces. The lesson: simplify ruthlessly before the system forces it.",
               source: "The Collapse of Complex Societies, Joseph Tainter"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AxisSpacing.base) {
                AxisCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            AxisTag(text: lessons[lessonIndex].category, color: .axisViolet)
                            Spacer()
                            Text("Lesson \(lessonIndex + 1) of \(lessons.count)")
                                .font(.axisMono(10))
                                .foregroundColor(.axisTextMuted)
                        }
                        Text(lessons[lessonIndex].title)
                            .font(.axisH1)
                            .foregroundColor(.axisTextPrimary)
                            .lineSpacing(2)
                        Text(lessons[lessonIndex].content)
                            .font(.axisBody1)
                            .foregroundColor(.axisTextSecondary)
                            .lineSpacing(5)
                        Text("Source: \(lessons[lessonIndex].source)")
                            .font(.axisMono(10))
                            .foregroundColor(.axisTextMuted)

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                lessonIndex = (lessonIndex + 1) % lessons.count
                            }
                        } label: {
                            Text("Next lesson \u{2192}")
                                .font(.axisBody(13, weight: .medium))
                                .foregroundColor(.axisViolet)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(14)
                }
                .padding(.horizontal, AxisSpacing.base)
            }
            .padding(.top, AxisSpacing.sm)
            .padding(.bottom, AxisSpacing.xl)
        }
    }
}

private struct Lesson {
    let category: String
    let title: String
    let content: String
    let source: String
}

#Preview {
    NavigationStack {
        BriefView()
    }
}
