import SwiftUI

struct SessionCardView: View {
    let session: Session
    let onHide: () -> Void

    private var statusColor: Color {
        switch session.status {
        case .working: return .blue
        case .waitingInput: return .orange
        case .idle: return .gray
        case .error: return .red
        }
    }

    private var statusIcon: String {
        switch session.status {
        case .working: return "circle.fill"
        case .waitingInput: return "exclamationmark.circle.fill"
        case .idle: return "circle"
        case .error: return "xmark.circle.fill"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .font(.system(size: 10))

                Text(session.projectName)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)

                Spacer()

                Button(action: onHide) {
                    Image(systemName: "eye.slash")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Hide session")
            }

            if let detail = session.statusDetail {
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            HStack(spacing: 12) {
                if let tokenUsage = session.tokenUsage {
                    Label(TokenFormatter.format(tokenUsage.total) + " tokens",
                          systemImage: "number.circle")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                if let started = session.startedAt {
                    Label(TimeFormatter.duration(from: started),
                          systemImage: "clock")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(TimeFormatter.relativeTime(from: session.updatedAt))
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .cornerRadius(6)
        .help(session.cwd)
    }
}
