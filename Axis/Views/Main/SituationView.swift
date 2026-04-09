import SwiftUI

struct SituationView: View {
    @Binding var selectedTab: Int
    @State private var brief: Brief?
    @State private var signals: [Signal] = []
    @State private var captures: [Capture] = []
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var showCapturedBanner = false
    @State private var captureFocusTrigger: Int = 0

    init(selectedTab: Binding<Int> = .constant(0)) {
        self._selectedTab = selectedTab
    }

    private var currentGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var currentTime: String {
        Date().formatted(date: .omitted, time: .shortened)
    }

    private var topSignal: Signal? {
        signals
            .filter { !$0.isCompleted && !$0.isSnoozed }
            .sorted { $0.urgency > $1.urgency }
            .first
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: AxisSpacing.lg) {
                    // Greeting header
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentGreeting)
                            .font(.axisH1)
                            .foregroundColor(.axisTextPrimary)
                        Text(currentTime)
                            .font(.axisMono(11))
                            .foregroundColor(.axisTextMuted)
                    }
                    .padding(.top, AxisSpacing.sm)

                    // Single unified capture prompt — always visible at top
                    CapturePromptCard(focusTrigger: captureFocusTrigger, onCapture: { text in
                        await submitCapture(text)
                    })
                    .transition(.opacity.combined(with: .move(edge: .bottom)))

                    // MORNING BRIEF
                    if let brief {
                        MorningBriefCard(brief: brief)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    // SIGNAL HERO
                    if let signal = topSignal {
                        SignalHeroCard(signal: signal, onComplete: {
                            await completeSignal(signal)
                        }, onSnooze: {
                            await snoozeSignal(signal)
                        })
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    // AXIS HANDLED
                    if let brief, brief.silentCount > 0 {
                        AxisHandledCard(silentCount: brief.silentCount)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, AxisSpacing.xl)
                .padding(.top, AxisSpacing.sm)
                .animation(.easeInOut(duration: 0.25), value: brief?.id)
                .animation(.easeInOut(duration: 0.25), value: signals.count)
            }
            .background(Color.axisBackground)
            .onChange(of: selectedTab) { _, newValue in
                if newValue == 0 {
                    captureFocusTrigger &+= 1
                }
            }

            // "Axis caught that" banner
            if showCapturedBanner {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                    Text("Axis caught that.")
                        .font(.axisBody(14, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.axisGreen)
                .cornerRadius(AxisRadius.pill)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if isLoading {
                SituationLoadingView()
            }
        }
        .task { await loadData() }
        .refreshable { await loadData() }
    }

    private func loadData() async {
        async let briefResult: Brief? = {
            try? await APIService.shared.request("/brief/today")
        }()
        async let signalsResult: [Signal] = {
            (try? await APIService.shared.request("/signal")) ?? []
        }()
        async let capturesResult: [Capture] = {
            (try? await APIService.shared.request("/capture")) ?? []
        }()

        brief = await briefResult
        signals = await signalsResult
        captures = await capturesResult
        isLoading = false
    }

    private func submitCapture(_ text: String) async {
        do {
            try await APIService.shared.requestVoid(
                "/capture",
                method: "POST",
                body: CaptureRequest(content: text)
            )
            // Show banner
            withAnimation(.easeInOut(duration: 0.3)) {
                showCapturedBanner = true
            }
            // Hide after 2 seconds, then reload
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeInOut(duration: 0.3)) {
                showCapturedBanner = false
            }
            await loadData()
        } catch { }
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

// MARK: - Morning Brief Card

private struct MorningBriefCard: View {
    let brief: Brief

    var body: some View {
        AxisCard(elevated: true, accent: true) {
            VStack(alignment: .leading, spacing: AxisSpacing.md) {
                // Header row
                HStack {
                    AxisTag(text: "Morning brief", color: .axisViolet)
                    Spacer()
                    Text(brief.generatedAt, style: .time)
                        .font(.axisMono(10))
                        .foregroundColor(.axisTextMuted)
                }

                // Brief messages
                ForEach(brief.messages) { message in
                    Text(message.content)
                        .font(.axisBody1)
                        .foregroundColor(.axisTextPrimary)
                        .lineSpacing(4)
                }

                // Sign-off
                Text("Your move.")
                    .font(.system(size: 14, weight: .regular).italic())
                    .foregroundColor(.axisTextMuted)

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
                }
            }
            .padding(AxisSpacing.base)
        }
        .padding(.bottom, AxisSpacing.xs)
    }
}

// MARK: - Signal Hero Card

private struct SignalHeroCard: View {
    let signal: Signal
    let onComplete: () async -> Void
    let onSnooze: () async -> Void

    private var urgencyColor: Color {
        switch signal.urgency {
        case 9...10: return .axisRed
        case 7...8: return .axisAmber
        default: return .axisViolet
        }
    }

    private var urgencyLabel: String {
        switch signal.urgency {
        case 9...10: return "Now"
        case 7...8:  return "Today"
        default:     return "When you can"
        }
    }

    var body: some View {
        AxisCard(elevated: true) {
            VStack(alignment: .leading, spacing: 0) {
                // Urgency bar
                Rectangle()
                    .fill(urgencyColor)
                    .frame(height: 3)

                VStack(alignment: .leading, spacing: AxisSpacing.md) {
                    // Label row
                    HStack {
                        AxisTag(text: urgencyLabel, color: urgencyColor)
                        Spacer()
                        Text(signal.createdAt, style: .relative)
                            .font(.axisMono(10))
                            .foregroundColor(.axisTextMuted)
                    }

                    // Signal title
                    Text(signal.title)
                        .font(.axisH1)
                        .foregroundColor(.axisTextPrimary)
                        .lineSpacing(2)

                    // Body
                    if let body = signal.body {
                        Text(body)
                            .font(.axisBody2)
                            .foregroundColor(.axisTextSecondary)
                            .lineSpacing(3)
                    }

                    // Action buttons
                    HStack(spacing: AxisSpacing.sm) {
                        if signal.actionable {
                            Button("Handle") {
                                Task { await onComplete() }
                            }
                            .font(.axisBody(14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, AxisSpacing.base)
                            .padding(.vertical, 10)
                            .background(Color.axisViolet)
                            .cornerRadius(AxisRadius.pill)
                            .buttonStyle(.plain)
                        }

                        Button("Later") {
                            Task { await onSnooze() }
                        }
                        .font(.axisBody2)
                        .foregroundColor(.axisTextSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.axisSurface2)
                        .cornerRadius(AxisRadius.pill)
                        .overlay(
                            RoundedRectangle(cornerRadius: AxisRadius.pill)
                                .stroke(Color.axisBorderDefault, lineWidth: 0.5)
                        )
                        .buttonStyle(.plain)

                        Spacer()

                        Button(action: { Task { await onComplete() } }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.axisGreen)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(AxisSpacing.base)
            }
        }
        .padding(.bottom, AxisSpacing.xs)
    }
}

// MARK: - Axis Handled Card

private struct AxisHandledCard: View {
    let silentCount: Int

    var body: some View {
        AxisCard {
            VStack(alignment: .leading, spacing: AxisSpacing.sm) {
                HStack {
                    Text("Handled silently")
                        .font(.axisMono(11))
                        .foregroundColor(.axisTextMuted)
                        .textCase(.uppercase)
                        .kerning(1.5)
                    Spacer()
                    Text("\(silentCount) items")
                        .font(.axisMono(11))
                        .foregroundColor(.axisViolet)
                }
            }
            .padding(14)
        }
        .padding(.bottom, AxisSpacing.xl)
    }
}

// MARK: - Loading & Empty States

private struct SituationLoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: AxisSpacing.base) {
            Image(systemName: "eye.fill")
                .font(.title2)
                .foregroundColor(.axisViolet)
                .opacity(isAnimating ? 0.4 : 1.0)

            Text("Loading situation...")
                .font(.axisBody2)
                .foregroundColor(.axisTextSecondary)
                .opacity(isAnimating ? 0.4 : 1.0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Capture Prompt Card (replaces empty state)

private struct CapturePromptCard: View {
    let focusTrigger: Int
    let onCapture: (String) async -> Void
    @State private var text = ""
    @State private var isSaving = false
    @FocusState private var isFocused: Bool

    var canSubmit: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSaving
    }

    var body: some View {
        AxisCard(elevated: true, accent: true) {
            VStack(alignment: .leading, spacing: AxisSpacing.md) {
                Text("What's on your mind?")
                    .font(.axisH2)
                    .foregroundColor(.axisTextPrimary)

                AxisTextField(
                    placeholder: "Anything you've been meaning to do...",
                    text: $text,
                    multiline: true
                )
                .focused($isFocused)
                .frame(minHeight: 80)

                if canSubmit {
                    Button {
                        isSaving = true
                        let content = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        text = ""
                        Task {
                            await onCapture(content)
                            isSaving = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.7)
                            }
                            Text(isSaving ? "Saving..." : "Tell Axis")
                        }
                        .font(.axisBody(14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.axisViolet)
                        .cornerRadius(AxisRadius.pill)
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(AxisSpacing.base)
            .task {
                try? await Task.sleep(for: .milliseconds(400))
                isFocused = true
            }
            .onChange(of: focusTrigger) { _, _ in
                isFocused = true
            }
        }
        .animation(.easeInOut(duration: 0.15), value: canSubmit)
    }
}
