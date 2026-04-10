import SwiftUI

struct SettingsView: View {
    @State private var connections: [Connection] = []
    @State private var contextNotes = ""
    @State private var isSavingNotes = false
    @State private var isLoading = true
    @State private var showSignOutConfirmation = false

    var onSignedOut: () -> Void

    var body: some View {
        List {
            // Connections
            Section("Connections") {
                if isLoading {
                    ProgressView()
                } else {
                    ForEach(connections) { connection in
                        ConnectionRow(connection: connection)
                    }
                }
            }

            // Context notes
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tell Axis about yourself — your role, work patterns, priorities. This feeds into every decision Axis makes.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextEditor(text: $contextNotes)
                        .frame(minHeight: 120)
                        .scrollContentBackground(.hidden)

                    Button {
                        saveNotes()
                    } label: {
                        Text(isSavingNotes ? "Saving..." : "Save")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(isSavingNotes)
                }
            } header: {
                Text("Context Notes")
            }

            // About
            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Tier", value: "Free")
                Link(destination: URL(string: "https://axis-web-chi.vercel.app")!) {
                    Text("Terms & Privacy")
                }
            }

            // Sign out
            Section {
                Button(role: .destructive) {
                    showSignOutConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Sign Out")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .task { await loadData() }
        .confirmationDialog("Sign out of Axis?", isPresented: $showSignOutConfirmation) {
            Button("Sign Out", role: .destructive) {
                KeychainService.shared.deleteAll()
                onSignedOut()
            }
        }
    }

    private func loadData() async {
        do {
            connections = try await APIService.shared.request("/connections")
        } catch { }

        do {
            struct NotesResponse: Decodable { let notes: String }
            let response: NotesResponse = try await APIService.shared.request("/context-notes")
            contextNotes = response.notes
        } catch { }

        isLoading = false
    }

    private func saveNotes() {
        isSavingNotes = true
        Task {
            do {
                try await APIService.shared.requestVoid(
                    "/context-notes",
                    method: "PUT",
                    body: ContextNotesRequest(notes: contextNotes)
                )
            } catch { }
            isSavingNotes = false
        }
    }
}

// MARK: - Connection Row

private struct ConnectionRow: View {
    let connection: Connection

    var body: some View {
        HStack {
            Image(systemName: iconForProvider(connection.provider))
                .foregroundStyle(connection.isConnected ? Color.accentColor : Color.secondary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(connection.label)
                    .font(.subheadline)
                if connection.isConnected {
                    Text("Connected")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }

            Spacer()

            if connection.isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Text("Connect")
                    .font(.caption.bold())
                    .foregroundStyle(Color.accentColor)
            }
        }
    }

    private func iconForProvider(_ provider: String) -> String {
        switch provider {
        case "gmail": return "envelope.fill"
        case "calendar": return "calendar"
        case "health": return "heart.fill"
        case "location": return "location.fill"
        case "stripe", "xero": return "dollarsign.circle.fill"
        case "slack": return "number"
        default: return "link"
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView { }
    }
}
