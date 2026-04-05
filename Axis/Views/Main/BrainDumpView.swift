import SwiftUI
import Speech

struct BrainDumpView: View {
    @State private var text = ""
    @State private var isProcessing = false
    @State private var showConfirmation = false
    @State private var isListening = false
    @FocusState private var isFocused: Bool

    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Capture")
                            .font(.title2.bold())
                        Text("Thoughts, ideas, anything. Axis will make sense of it.")
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
                        .background(Color.axisSurface1, in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        .overlay(alignment: .topLeading) {
                            if text.isEmpty && !isListening {
                                Text("What's on your mind?")
                                    .foregroundStyle(.tertiary)
                                    .padding(.horizontal, 32)
                                    .padding(.top, 24)
                                    .allowsHitTesting(false)
                            }
                        }

                    // Buttons
                    HStack(spacing: 12) {
                        Button {
                            toggleSpeechRecognition()
                        } label: {
                            Label(isListening ? "Stop" : "Voice",
                                  systemImage: isListening ? "stop.circle.fill" : "mic.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .tint(isListening ? .red : nil)

                        Button {
                            submit()
                        } label: {
                            Label("Capture", systemImage: "arrow.up.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
                    }
                    .padding(.horizontal)

                    // Confirmation
                    if showConfirmation {
                        Text("Got it.")
                            .font(.body.bold())
                            .foregroundStyle(Color.accentColor)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .transition(.opacity)
                    }
                }
                .padding(.vertical)
            }
            .onTapGesture { hideKeyboard() }

            if isProcessing {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(Color.accentColor)
                    Text("Processing...")
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
        .background(Color.axisBackground)
    }

    // MARK: - Submit

    private func submit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isProcessing = true
        isFocused = false

        Task {
            do {
                let _: BrainDumpResponse = try await APIService.shared.request(
                    "/brain-dump",
                    method: "POST",
                    body: ["content": trimmed]
                )
            } catch { }

            text = ""
            isProcessing = false
            withAnimation { showConfirmation = true }

            try? await Task.sleep(for: .seconds(3))
            withAnimation { showConfirmation = false }
        }
    }

    // MARK: - Speech Recognition

    private func toggleSpeechRecognition() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }

    private func startListening() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else { return }

            DispatchQueue.main.async {
                guard let speechRecognizer, speechRecognizer.isAvailable else { return }

                let request = SFSpeechAudioBufferRecognitionRequest()
                request.shouldReportPartialResults = true

                let inputNode = audioEngine.inputNode
                let recordingFormat = inputNode.outputFormat(forBus: 0)
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                    request.append(buffer)
                }

                audioEngine.prepare()
                do {
                    try audioEngine.start()
                    isListening = true
                } catch {
                    return
                }

                recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
                    if let result {
                        text = result.bestTranscription.formattedString
                    }
                    if error != nil || (result?.isFinal ?? false) {
                        stopListening()
                    }
                }
            }
        }
    }

    private func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
    }
}

#Preview {
    NavigationStack {
        BrainDumpView()
    }
}
