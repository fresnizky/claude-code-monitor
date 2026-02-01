import SwiftUI

struct PopoverView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Claude Code")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                if !viewModel.state.visibleSessions.isEmpty {
                    Text("\(viewModel.state.visibleSessions.count) session\(viewModel.state.visibleSessions.count == 1 ? "" : "s")")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // Session list
            ScrollView {
                VStack(spacing: 4) {
                    let visible = viewModel.state.visibleSessions
                    if visible.isEmpty {
                        EmptyStateView()
                    } else {
                        ForEach(visible) { session in
                            SessionCardView(session: session) {
                                viewModel.hideSession(session.sessionId)
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .frame(maxHeight: 400)

            // Hidden sessions
            let hidden = viewModel.state.hiddenSessionObjects
            if !hidden.isEmpty {
                Divider()
                HiddenSessionsView(sessions: hidden) { sessionId in
                    viewModel.unhideSession(sessionId)
                }
                .padding(.vertical, 6)
            }

            Divider()

            // Quit button
            Button(action: { NSApplication.shared.terminate(nil) }) {
                Text("Quit")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 350)
    }
}
