import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "terminal")
                .font(.system(size: 24))
                .foregroundColor(.secondary)
            Text("No active sessions")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            Text("Start a Claude Code session to see it here")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
