import Foundation

enum SessionStatus: String, Codable {
    case working
    case waitingInput = "waiting_input"
    case idle
    case error
}

struct TokenUsage: Codable, Equatable {
    var input: Int
    var output: Int

    var total: Int { input + output }

    enum CodingKeys: String, CodingKey {
        case input
        case output
    }
}

struct Session: Codable, Identifiable, Equatable {
    var sessionId: String
    var cwd: String
    var status: SessionStatus
    var statusDetail: String?
    var updatedAt: Date
    var startedAt: Date?
    var tokenUsage: TokenUsage?

    var id: String { sessionId }

    var projectName: String {
        (cwd as NSString).lastPathComponent
    }

    var isStale: Bool {
        Date().timeIntervalSince(updatedAt) > 24 * 60 * 60
    }

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case cwd
        case status
        case statusDetail = "status_detail"
        case updatedAt = "updated_at"
        case startedAt = "started_at"
        case tokenUsage = "token_usage"
    }
}
