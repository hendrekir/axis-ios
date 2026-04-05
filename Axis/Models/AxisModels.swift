import Foundation

// MARK: - User

struct AxisUser: Codable, Identifiable {
    let id: UUID
    let email: String
    let name: String?
    let avatarUrl: String?
    let tier: Tier
    let createdAt: Date

    enum Tier: String, Codable {
        case free
        case pro
        case team
    }
}

// MARK: - Thread

struct ThreadMessage: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let sender: Sender
    let content: String
    let contentType: ContentType
    let actionType: ActionType?
    let actionPayload: String?
    let urgency: Int?
    let surface: String?
    let readAt: Date?
    let createdAt: Date

    enum Sender: String, Codable {
        case user
        case axis
    }

    enum ContentType: String, Codable {
        case text
        case brainDump = "brain_dump"
        case digest
        case emailDraft = "email_draft"
        case taskUpdate = "task_update"
        case signal
        case action
    }

    enum ActionType: String, Codable {
        case sendReply = "send_reply"
        case createTask = "create_task"
        case markDone = "mark_done"
        case snooze
        case dismiss
        case none
    }

    var isFromAxis: Bool { sender == .axis }
    var isActionable: Bool { actionType != nil && actionType != ThreadMessage.ActionType.none }
}

// MARK: - Signal

struct Signal: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let title: String
    let body: String?
    let urgency: Int
    let actionable: Bool
    let actionType: ThreadMessage.ActionType?
    let actionPayload: String?
    let category: Category
    let source: String?
    let completedAt: Date?
    let snoozedUntil: Date?
    let createdAt: Date

    enum Category: String, Codable {
        case email
        case calendar
        case finance
        case health
        case task
        case admin
        case other
    }

    var isCompleted: Bool { completedAt != nil }
    var isSnoozed: Bool {
        guard let until = snoozedUntil else { return false }
        return until > Date()
    }
}

// MARK: - Task

struct AxisTask: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let title: String
    let body: String?
    let priority: Int
    let category: Signal.Category
    let dueDate: Date?
    let completedAt: Date?
    let source: String?
    let createdAt: Date

    var isCompleted: Bool { completedAt != nil }
}

// MARK: - Skill

struct Skill: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let isBuiltin: Bool
    let isActive: Bool
    let dataSources: [String]?
    let reasoningModel: String?
    let triggerType: String?
    let outputRouting: String?
    let systemPrompt: String?

    var isConnected: Bool { isActive }

    var icon: String {
        let lower = name.lowercased()
        if lower.contains("email") || lower.contains("gmail") { return "envelope.fill" }
        if lower.contains("calendar") { return "calendar" }
        if lower.contains("finance") || lower.contains("invoice") { return "dollarsign.circle.fill" }
        if lower.contains("research") { return "magnifyingglass" }
        if lower.contains("entertainment") || lower.contains("music") { return "music.note" }
        if lower.contains("morning") || lower.contains("brief") { return "sun.max.fill" }
        return "cpu"
    }
}

// MARK: - Brief

struct Brief: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let messages: [BriefMessage]
    let silentCount: Int
    let calendarEvents: [CalendarEvent]?
    let gmailConnected: Bool?
    let generatedAt: Date

    struct BriefMessage: Codable, Identifiable {
        let id: UUID
        let content: String
        let category: String?
    }

    struct CalendarEvent: Codable, Identifiable {
        let id: UUID
        let title: String
        let startTime: Date
        let endTime: Date?
        let location: String?
    }
}

// MARK: - Brain Dump

struct BrainDumpRequest: Encodable {
    let text: String
    let source: String // "text" or "voice"
}

struct BrainDumpResponse: Decodable {
    let tasks: [AxisTask]
    let threadMessages: [ThreadMessage]
}

// MARK: - Interaction logging

struct InteractionLog: Encodable {
    let surface: String
    let contentType: String
    let contentId: String?
    let actionTaken: String
    let responseTimeMs: Int?
    let mode: String?
}

// MARK: - Context Notes

struct ContextNotesRequest: Encodable {
    let notes: String
}

struct ContextSetupPayload: Encodable {
    let contextNotes: String
    let timezone: String
}

// MARK: - Connection

struct Connection: Codable, Identifiable {
    let id: UUID
    let provider: String
    let label: String
    let isConnected: Bool
    let connectedAt: Date?
}

// MARK: - Apprentice Insight

struct ApprenticeInsight: Codable, Identifiable {
    let id: UUID
    let title: String
    let body: String
    let category: String
    let confidence: Double
    let weekOf: Date
    let createdAt: Date
}
