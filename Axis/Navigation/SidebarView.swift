import SwiftUI
import ClerkKit

struct SidebarView: View {
    @Binding var isVisible: Bool
    var onSignedOut: () -> Void

    @State private var activeDestination: SidebarDestination?

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                SidebarHeader()
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                Divider()
                    .background(Color.axisBorderDefault)
                    .padding(.vertical, 16)

                SidebarNavItem(icon: "waveform", label: "Signal") {
                    activeDestination = .signal
                }
                SidebarNavItem(icon: "calendar", label: "Schedule") {
                    activeDestination = .schedule
                }
                SidebarNavItem(icon: "link", label: "Connections") {
                    activeDestination = .connections
                }
                SidebarNavItem(icon: "wand.and.stars", label: "Capabilities") {
                    activeDestination = .capabilities
                }

                Spacer()

                Divider().background(Color.axisBorderDefault)

                SidebarNavItem(icon: "gearshape.fill", label: "Settings") {
                    activeDestination = .settings
                }
                .padding(.bottom, 32)
            }
            .frame(width: min(UIScreen.main.bounds.width * 0.8, 320))
            .background(Color.axisSurface1)

            Color.black.opacity(0.5)
                .onTapGesture { isVisible = false }
        }
        .ignoresSafeArea()
        .sheet(item: $activeDestination) { destination in
            NavigationStack {
                destination.view(onSignedOut: onSignedOut)
                    .background(Color.axisBackground)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button { activeDestination = nil } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.axisTextSecondary)
                            }
                        }
                    }
            }
        }
    }
}

// MARK: - Destinations

private enum SidebarDestination: String, Identifiable {
    case signal, schedule, connections, capabilities, settings
    var id: String { rawValue }

    @ViewBuilder
    func view(onSignedOut: @escaping () -> Void) -> some View {
        switch self {
        case .signal:       SidebarSignalView()
        case .schedule:     SidebarScheduleView()
        case .connections:  SidebarConnectionsView()
        case .capabilities: SidebarCapabilitiesView()
        case .settings:     SidebarSettingsView(onSignedOut: onSignedOut)
        }
    }
}

// MARK: - Signal View

private struct SidebarSignalView: View {
    @State private var signals: [Signal] = []
    @State private var isLoading = true
    @State private var selectedFilter = 0

    var filteredSignals: [Signal] {
        let active = signals.filter { !$0.isCompleted && !$0.isSnoozed }
        switch selectedFilter {
        case 0: return active.filter { $0.urgency >= 8 }      // Now
        case 1: return active.filter { (5...7).contains($0.urgency) }  // Today
        case 2: return active.filter { $0.urgency < 5 }       // When you can
        default: return active
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedFilter) {
                Text("Now").tag(0)
                Text("Today").tag(1)
                Text("When you can").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, AxisSpacing.base)
            .padding(.vertical, AxisSpacing.sm)

            ScrollView {
                LazyVStack(spacing: AxisSpacing.sm) {
                    if filteredSignals.isEmpty {
                        VStack(spacing: AxisSpacing.sm) {
                            Image(systemName: "bell.slash")
                                .font(.title2)
                                .foregroundColor(.axisTextMuted)
                            Text("Nothing urgent right now. Axis is watching.")
                                .font(.axisBody2)
                                .foregroundColor(.axisTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 60)
                    } else {
                        ForEach(filteredSignals) { signal in
                            SidebarSignalCard(signal: signal)
                        }
                    }
                }
                .padding(.horizontal, AxisSpacing.base)
                .padding(.top, AxisSpacing.sm)
            }
        }
        .navigationTitle("Signal")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                signals = try await APIService.shared.request("/signal")
            } catch { }
            isLoading = false
        }
        .overlay {
            if isLoading {
                ProgressView().tint(.axisViolet)
            }
        }
    }
}

private struct SidebarSignalCard: View {
    let signal: Signal

    private var urgencyColor: Color {
        switch signal.urgency {
        case 8...10: return .axisRed
        case 5...7:  return .axisAmber
        default:     return .axisViolet
        }
    }
    private var urgencyLabel: String {
        switch signal.urgency {
        case 8...10: return "Now"
        case 5...7:  return "Today"
        default:     return "When you can"
        }
    }

    var body: some View {
        AxisCard {
            VStack(alignment: .leading, spacing: AxisSpacing.sm) {
                HStack {
                    AxisTag(text: urgencyLabel, color: urgencyColor)
                    Spacer()
                    Text(signal.createdAt, style: .relative)
                        .font(.axisMono(10))
                        .foregroundColor(.axisTextMuted)
                }
                Text(signal.title)
                    .font(.axisH1)
                    .foregroundColor(.axisTextPrimary)
                    .lineSpacing(2)
                if let body = signal.body {
                    Text(body)
                        .font(.axisBody2)
                        .foregroundColor(.axisTextSecondary)
                        .lineLimit(2)
                }
            }
            .padding(14)
        }
    }
}

// MARK: - Schedule View (READ-ONLY)

private struct SidebarScheduleView: View {
    @State private var events: [Brief.CalendarEvent] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AxisSpacing.sm) {
                if events.isEmpty && !isLoading {
                    VStack(spacing: AxisSpacing.sm) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.axisTextMuted)
                        Text("No events today.")
                            .font(.axisBody2)
                            .foregroundColor(.axisTextSecondary)
                        Text("Tell Axis in the chat tab to schedule anything.")
                            .font(.axisMono(10))
                            .foregroundColor(.axisTextMuted)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    ForEach(events) { event in
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.axisViolet)
                                .frame(width: 4, height: 44)

                            VStack(alignment: .leading, spacing: 3) {
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
                        .padding(.vertical, 6)
                    }
                }
            }
            .padding(.top, AxisSpacing.sm)
        }
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Load today's events from brief
            do {
                let brief: Brief = try await APIService.shared.request("/brief/today")
                events = brief.calendarEvents ?? []
            } catch { }
            isLoading = false
        }
        .overlay {
            if isLoading {
                ProgressView().tint(.axisViolet)
            }
        }
    }
}

// MARK: - Connections View

private struct SidebarConnectionsView: View {
    @State private var connections: [Connection] = []
    @State private var isLoading = true
    @State private var clerkId: String = ""

    private static let baseURL = "https://web-production-32f5d.up.railway.app"

    private struct ServiceInfo: Identifiable {
        let id = UUID()
        let icon: String
        let name: String
        let color: Color
        let oauthPath: String?  // nil = no OAuth yet
    }

    private let services: [ServiceInfo] = [
        ServiceInfo(icon: "envelope.fill", name: "Gmail", color: .axisRed, oauthPath: "/auth/gmail"),
        ServiceInfo(icon: "calendar", name: "Google Calendar", color: .axisAmber, oauthPath: "/auth/calendar"),
        ServiceInfo(icon: "music.note", name: "Spotify", color: .axisGreen, oauthPath: "/auth/spotify"),
        ServiceInfo(icon: "dollarsign.circle.fill", name: "Stripe", color: .axisViolet, oauthPath: nil),
    ]

    /// Decode the `sub` claim from a JWT without signature verification.
    private static func extractSub(from jwt: String) -> String? {
        let parts = jwt.split(separator: ".")
        guard parts.count >= 2 else { return nil }
        var payload = String(parts[1])
        // Base64URL → Base64
        payload = payload.replacingOccurrences(of: "-", with: "+")
                         .replacingOccurrences(of: "_", with: "/")
        while payload.count % 4 != 0 { payload += "=" }
        guard let data = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let sub = json["sub"] as? String else { return nil }
        return sub
    }

    private func isConnected(_ name: String) -> Bool {
        connections.contains { $0.provider.lowercased() == name.lowercased() && $0.isConnected }
    }

    private func connectService(_ service: ServiceInfo) {
        guard let path = service.oauthPath,
              let url = URL(string: "\(Self.baseURL)\(path)?clerk_id=\(clerkId)") else { return }
        UIApplication.shared.open(url)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AxisSpacing.sm) {
                ForEach(services) { service in
                    let connected = isConnected(service.name)

                    Button {
                        if !connected { connectService(service) }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: service.icon)
                                .font(.system(size: 16))
                                .foregroundColor(connected ? service.color : .axisTextMuted)
                                .frame(width: 36, height: 36)
                                .background(connected ? service.color.opacity(0.12) : Color.axisSurface2)
                                .cornerRadius(AxisRadius.sm)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(service.name)
                                    .font(.axisH2)
                                    .foregroundColor(.axisTextPrimary)
                                Text(connected ? "Connected" : "Not connected")
                                    .font(.axisMono(10))
                                    .foregroundColor(connected ? .axisGreen : .axisTextMuted)
                            }

                            Spacer()

                            if connected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.axisGreen)
                                    .font(.system(size: 16))
                            } else if service.oauthPath != nil {
                                Text("Connect")
                                    .font(.axisBody(13, weight: .medium))
                                    .foregroundColor(.axisViolet)
                            } else {
                                Text("Coming soon")
                                    .font(.axisMono(10))
                                    .foregroundColor(.axisTextMuted)
                            }
                        }
                        .padding(14)
                        .background(Color.axisSurface1)
                        .cornerRadius(AxisRadius.md)
                    }
                    .buttonStyle(.plain)
                    .disabled(connected || service.oauthPath == nil)
                }
            }
            .padding(.horizontal, AxisSpacing.base)
            .padding(.top, AxisSpacing.sm)
        }
        .navigationTitle("Connections")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Load clerk ID for OAuth URLs
            #if targetEnvironment(simulator)
            clerkId = "dev_simulator"
            #else
            // Try Clerk session first, then dev token
            if let user = Clerk.shared.user {
                clerkId = user.id
            } else if let devToken = KeychainService.shared.get(.clerkJWT) {
                clerkId = Self.extractSub(from: devToken) ?? ""
            }
            #endif

            do {
                connections = try await APIService.shared.request("/connections")
            } catch { }
            isLoading = false
        }
    }
}

// MARK: - Capabilities View (Skills)

private struct SidebarCapabilitiesView: View {
    @State private var skills: [Skill] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AxisSpacing.sm) {
                if skills.isEmpty && !isLoading {
                    VStack(spacing: AxisSpacing.sm) {
                        Image(systemName: "cpu")
                            .font(.title2)
                            .foregroundColor(.axisTextMuted)
                        Text("Skills will appear here as you connect services.")
                            .font(.axisBody2)
                            .foregroundColor(.axisTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(skills) { skill in
                        HStack(spacing: 12) {
                            Image(systemName: skill.icon)
                                .font(.system(size: 16))
                                .foregroundColor(.axisViolet)
                                .frame(width: 36, height: 36)
                                .background(Color.axisVioletDim)
                                .cornerRadius(AxisRadius.sm)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(skill.name)
                                    .font(.axisH2)
                                    .foregroundColor(.axisTextPrimary)
                                Text(skill.description)
                                    .font(.axisBody2)
                                    .foregroundColor(.axisTextSecondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Circle()
                                .fill(skill.isConnected ? Color.axisGreen : Color.axisTextMuted.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                        .padding(14)
                        .background(Color.axisSurface1)
                        .cornerRadius(AxisRadius.md)
                    }
                }
            }
            .padding(.horizontal, AxisSpacing.base)
            .padding(.top, AxisSpacing.sm)
        }
        .navigationTitle("Capabilities")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                skills = try await APIService.shared.request("/skills")
            } catch { }
            isLoading = false
        }
        .overlay {
            if isLoading {
                ProgressView().tint(.axisViolet)
            }
        }
    }
}

// MARK: - Settings View

private struct SidebarSettingsView: View {
    var onSignedOut: () -> Void
    @State private var contextNotes = ""
    @State private var showDeleteConfirm = false

    var body: some View {
        List {
            Section {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.axisVioletDim)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.axisViolet)
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Account")
                            .font(.axisH2)
                            .foregroundColor(.axisTextPrimary)
                        Text("Manage your Axis account")
                            .font(.axisMono(10))
                            .foregroundColor(.axisTextMuted)
                    }
                }
                .listRowBackground(Color.axisSurface1)
            }

            Section("What Axis should always know") {
                TextEditor(text: $contextNotes)
                    .font(.axisBody1)
                    .foregroundColor(.axisTextPrimary)
                    .frame(minHeight: 80)
                    .scrollContentBackground(.hidden)
                    .listRowBackground(Color.axisSurface1)
            }

            Section("Intelligence") {
                NavigationLink {
                    SidebarApprenticeView()
                } label: {
                    Label("What Axis learned", systemImage: "brain")
                }
                .listRowBackground(Color.axisSurface1)
            }

            Section("Privacy & Data") {
                Link(destination: URL(string: "https://tryaxis.app/privacy")!) {
                    Label("Privacy Policy", systemImage: "lock.shield")
                }
                .listRowBackground(Color.axisSurface1)

                Button {
                    showDeleteConfirm = true
                } label: {
                    Label("Delete my account", systemImage: "trash")
                        .foregroundColor(.axisRed)
                }
                .listRowBackground(Color.axisSurface1)
            }

            Section {
                Button {
                    onSignedOut()
                } label: {
                    Text("Sign out")
                        .foregroundColor(.axisRed)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowBackground(Color.axisSurface1)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { }
        } message: {
            Text("This will permanently delete your Axis account and all data. This cannot be undone.")
        }
    }
}

// MARK: - Apprentice View (inside Settings)

private struct SidebarApprenticeView: View {
    @State private var insights: [ApprenticeInsight] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AxisSpacing.sm) {
                if insights.isEmpty && !isLoading {
                    VStack(spacing: AxisSpacing.sm) {
                        Image(systemName: "brain.head.profile")
                            .font(.title2)
                            .foregroundColor(.axisTextMuted)
                        Text("Axis is still learning about you.")
                            .font(.axisBody2)
                            .foregroundColor(.axisTextSecondary)
                        Text("Insights will appear after your first week.")
                            .font(.axisMono(10))
                            .foregroundColor(.axisTextMuted)
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(insights) { insight in
                        AxisCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    AxisTag(text: insight.category, color: .axisViolet)
                                    Spacer()
                                    Text("\(Int(insight.confidence * 100))% confident")
                                        .font(.axisMono(10))
                                        .foregroundColor(.axisTextMuted)
                                }
                                Text(insight.title)
                                    .font(.axisH2)
                                    .foregroundColor(.axisTextPrimary)
                                Text(insight.body)
                                    .font(.axisBody2)
                                    .foregroundColor(.axisTextSecondary)
                                    .lineSpacing(3)
                            }
                            .padding(14)
                        }
                    }
                }
            }
            .padding(.horizontal, AxisSpacing.base)
            .padding(.top, AxisSpacing.sm)
        }
        .background(Color.axisBackground)
        .navigationTitle("What Axis learned")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                insights = try await APIService.shared.request("/apprentice")
            } catch { }
            isLoading = false
        }
    }
}

// MARK: - Reusable Components

struct SidebarHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            AxisMark(size: 28, color: .axisViolet)
            VStack(alignment: .leading, spacing: 2) {
                Text("AXIS")
                    .font(.axisSyne(18))
                    .foregroundColor(.axisTextPrimary)
                Text("extend the mind")
                    .font(.axisMono(9))
                    .foregroundColor(.axisViolet.opacity(0.4))
                    .kerning(2)
            }
        }
    }
}

struct SidebarNavItem: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.axisViolet)
                    .frame(width: 22)
                Text(label)
                    .font(.axisBody(15, weight: .medium))
                    .foregroundColor(.axisTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.axisTextMuted)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .background(Color.clear)
        .contentShape(Rectangle())
    }
}
