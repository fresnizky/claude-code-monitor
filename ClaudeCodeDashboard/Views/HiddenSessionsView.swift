import SwiftUI

struct HiddenSessionsView: View {
    let sessions: [Session]
    let onUnhide: (String) -> Void

    var body: some View {
        if !sessions.isEmpty {
            DisclosureGroup {
                ForEach(sessions) { session in
                    HStack {
                        Text(session.projectName)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)

                        Spacer()

                        Button(action: { onUnhide(session.sessionId) }) {
                            Image(systemName: "eye")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help("Unhide session")
                    }
                    .padding(.vertical, 2)
                }
            } label: {
                Text("Hidden (\(sessions.count))")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
        }
    }
}
