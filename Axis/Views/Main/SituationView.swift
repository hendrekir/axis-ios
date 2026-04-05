import SwiftUI

struct SituationView: View {
    @State private var brief: Brief?
    @State private var signals: [Signal] = []
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var showContextSetup = false
    @State private var contextText = ""
    @State private var isSavingContext = false
    @State private var contextSaved = false

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
        ScrollView {
            VStack(alignment: .leading, spacing: AxisSpacing.base) {
                // MORNING BRIEF
                if let brief {
                    MorningBriefCard(brief: brief)
                }

                // SIGNAL HERO
                if let signal = topSignal {
                    SignalHeroCard(signal: signal, onComplete: {
                        await completeSignal(signal)
                    }, onSnooze: {
                        await snoozeSignal(signal)
                    })
                }

                // AXIS HANDLED
                if let brief, brief.silentCount > 0 {
                    AxisHandledCard(silentCount: brief.silentCount)
                }
            }
            .padding(.horizontal, AxisSpacing.base)
            .padding(.top, AxisSpacing.sm)
        }
        .background(Color.axisBackground)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                VStack(alignment: .trailing, spacing: 1) {
                    Text(currentGreeting)
                        .font(.axisMono(10))
                        .foregroundColor(.axisTextMuted)
                    Text(currentTime)
                        .font(.axisMono(11))
                        .foregroundColor(.axisTextSecondary)
                }
            }
        }
        .overlay {
            if isLoading {
                SituationLoadingView()
            }
            if !isLoading && brief == nil && signals.isEmpty && !showContextSetup {
                SituationEmptyView(loadFailed: loadFailed)
            }
        }
        .sheet(isPresented: $showContextSetup) {
            ContextSetupSheet(
                contextText: $contextText,
                isSaving: $isSavingContext,
                saved: $contextSaved,
                onSave: { await saveContext() }
            )
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

        brief = await briefResult
        signals = await signalsResult
        isLoading = false

        // Simulator: if no data after load, prompt context setup after 3s
        #if targetEnvironment(simulator)
        if brief == nil && signals.isEmpty && !contextSaved {
            try? await Task.sleep(for: .seconds(3))
            if brief == nil && signals.isEmpty {
                showContextSetup = true
            }
        }
        #endif
    }

    private func saveContext() async {
        isSavingContext = true
        do {
            let payload = ContextSetupPayload(
                contextNotes: contextText,
                timezone: TimeZone.current.identifier
            )
            try await APIService.shared.requestVoid("/me", method: "PATCH", body: payload)
            contextSaved = true
            showContextSetup = false
            // Reload to pick up any new signals generated from context
            isLoading = true
            await loadData()
        } catch { }
        isSavingContext = false
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
                    .font(Font.custom("InstrumentSans-Regular", size: 14).italic())
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

private struct SituationEmptyView: View {
    let loadFailed: Bool

    var body: some View {
        ContentUnavailableView(
            loadFailed ? "Couldn't load" : "All clear",
            systemImage: loadFailed ? "exclamationmark.triangle" : "checkmark.seal",
            description: Text(loadFailed
                ? "Pull down to try again."
                : "No signals right now. Axis is watching.")
        )
    }
}

// MARK: - Context Setup Sheet (Simulator onboarding)

private struct ContextSetupSheet: View {
    @Binding var contextText: String
    @Binding var isSaving: Bool
    @Binding var saved: Bool
    let onSave: () async -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AxisSpacing.base) {
                VStack(alignment: .leading, spacing: AxisSpacing.sm) {
                    Text("Set up context")
                        .font(.axisSyne(22))
                        .foregroundColor(.axisTextPrimary)
                    Text("Tell Axis about your work, projects, goals, and the people that matter. This seeds the dispatch job with real data.")
                        .font(.axisBody2)
                        .foregroundColor(.axisTextSecondary)
                        .lineSpacing(3)
                }

                TextEditor(text: $contextText)
                    .font(.axisBody1)
                    .foregroundColor(.axisTextPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .frame(minHeight: 160)
                    .background(Color.axisSurface2)
                    .cornerRadius(AxisRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: AxisRadius.md)
                            .stroke(Color.axisBorderInput, lineWidth: 0.5)
                    )
                    .overlay(alignment: .topLeading) {
                        if contextText.isEmpty {
                            Text("Your work, projects, goals, the people that matter...")
                                .font(.axisBody1)
                                .foregroundColor(.axisTextMuted)
                                .padding(16)
                                .allowsHitTesting(false)
                        }
                    }

                Button {
                    Task { await onSave() }
                } label: {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        }
                        Text(isSaving ? "Saving..." : "Save context")
                    }
                    .font(.axisBody(15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(contextText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.axisViolet.opacity(0.4)
                        : Color.axisViolet)
                    .cornerRadius(AxisRadius.md)
                }
                .buttonStyle(.plain)
                .disabled(contextText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)

                Spacer()
            }
            .padding(AxisSpacing.base)
            .background(Color.axisBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        saved = true
                    }
                    .font(.axisBody2)
                    .foregroundColor(.axisTextSecondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
