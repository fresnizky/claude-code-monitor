import Foundation

enum TimeFormatter {
    static func duration(from start: Date, to end: Date = Date()) -> String {
        let interval = Int(end.timeIntervalSince(start))
        if interval < 0 { return "0m" }

        let hours = interval / 3600
        let minutes = (interval % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    static func relativeTime(from date: Date) -> String {
        let interval = Int(Date().timeIntervalSince(date))
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            return "\(interval / 60)m ago"
        } else if interval < 86400 {
            return "\(interval / 3600)h ago"
        }
        return "\(interval / 86400)d ago"
    }
}
