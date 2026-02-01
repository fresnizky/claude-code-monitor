import SwiftUI

@main
struct ClaudeCodeDashboardApp: App {
    var body: some Scene {
        MenuBarExtra("Claude Code Dashboard", systemImage: "circle") {
            Text("Claude Code Dashboard")
                .padding()
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
