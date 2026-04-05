import SwiftUI

struct BrainDumpView: View {
    @State private var text = ""
    @State private var isProcessing = false
    @State private var result: BrainDumpResponse?
    @State private var showResult = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Brain Dump")
                            .font(.title2.bold())
                        Text("Get it out of your head. Axis will sort it.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    // Text input
                    TextEditor(text: $text)
                        .focused($isFocused)
                        .foregroundStyle(.primary)
                        .tint(Color.accentColor)
                        .frame(minHeight: 200)
                        .scrollContentBackground(.hidden)
                        .padding(16)
                        .background(Color("AxisCard"), in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        .overlay(alignment: .topLeading) {
                            if text.isEmpty {
                                Text("What's on your mind? Tasks, ideas, reminders, random thoughts...")
                                    .foregroundStyle(.tertiary)
                                    .padding(.horizontal, 32)
                                    .padding(.top, 24)
                                    .allowsHitTesting(false)
                            }
                        }

                    // Buttons
                    HStack(spacing: 12) {
                        Button {
                            // TODO: voice input via Speech framework
                        } label: {
                            Label("Voice", systemImage: "mic.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)

                        Button {
                            submit()
                        } label: {
                            Label("Process", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .onTapGesture { hideKeyboard() }

            if isProcessing {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Axis is processing...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.bar)
            }
        }
        .navigationTitle("Mind")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("AxisBackground"))
        .sheet(isPresented: $showResult) {
            if let result {
                BrainDumpResultSheet(result: result)
            }
        }
        .onAppear { isFocused = true }
    }

    private func submit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isProcessing = true
        isFocused = false

        Task {
            do {
                let response: BrainDumpResponse = try await APIService.shared.request(
                    "/brain-dump",
                    method: "POST",
                    body: ["content": trimmed]
                )
                result = response
                text = ""
                showResult = true
            } catch { }
            isProcessing = false
        }
    }
}

// MARK: - Result Sheet

private struct BrainDumpResultSheet: View {
    let result: BrainDumpResponse
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if !result.tasks.isEmpty {
                    Section("Tasks created") {
                        ForEach(result.tasks) { task in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.title)
                                    .font(.subheadline.bold())
                                if let body = task.body {
                                    Text(body)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                }

                if !result.threadMessages.isEmpty {
                    Section("Added to thread") {
                        ForEach(result.threadMessages) { msg in
                            Text(msg.content)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Processed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BrainDumpView()
    }
}
