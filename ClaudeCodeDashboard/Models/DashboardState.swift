import Foundation

struct DashboardState: Codable, Equatable {
    var version: Int = 1
    var sessions: [Session] = []
    var hiddenSessions: [String] = []

    var visibleSessions: [Session] {
        sessions.filter { !hiddenSessions.contains($0.sessionId) }
    }

    var hiddenSessionObjects: [Session] {
        sessions.filter { hiddenSessions.contains($0.sessionId) }
    }

    enum CodingKeys: String, CodingKey {
        case version
        case sessions
        case hiddenSessions = "hidden_sessions"
    }

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()
}
