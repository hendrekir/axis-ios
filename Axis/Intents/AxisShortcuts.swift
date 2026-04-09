import AppIntents

/// Registers all Axis Siri phrases so they appear in Spotlight and Shortcuts.
struct AxisShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddToAxisIntent(),
            phrases: [
                "Add to \(.applicationName)",
                "Tell \(.applicationName) something",
                "Capture in \(.applicationName)"
            ],
            shortTitle: "Add to Axis",
            systemImageName: "plus.circle.fill"
        )

        AppShortcut(
            intent: GetSignalIntent(),
            phrases: [
                "What's my \(.applicationName) signal",
                "\(.applicationName) what needs attention"
            ],
            shortTitle: "Get Signal",
            systemImageName: "bell.fill"
        )

        AppShortcut(
            intent: MarkSignalDoneIntent(),
            phrases: [
                "Mark my \(.applicationName) signal done",
                "\(.applicationName) mark done"
            ],
            shortTitle: "Mark Done",
            systemImageName: "checkmark.circle.fill"
        )

        AppShortcut(
            intent: GetBriefIntent(),
            phrases: [
                "What's on today \(.applicationName)",
                "\(.applicationName) what's happening today",
                "What's in my \(.applicationName) brief",
                "\(.applicationName) morning brief"
            ],
            shortTitle: "Today's Brief",
            systemImageName: "doc.text.fill"
        )

        AppShortcut(
            intent: SetModeIntent(),
            phrases: [
                "Switch \(.applicationName) mode",
                "\(.applicationName) switch mode"
            ],
            shortTitle: "Set Mode",
            systemImageName: "arrow.triangle.swap"
        )

        AppShortcut(
            intent: SendReplyIntent(),
            phrases: [
                "Send that \(.applicationName) reply",
                "\(.applicationName) send reply"
            ],
            shortTitle: "Send Reply",
            systemImageName: "paperplane.fill"
        )
    }
}
