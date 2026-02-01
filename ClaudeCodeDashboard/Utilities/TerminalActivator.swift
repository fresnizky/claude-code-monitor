import AppKit
import Foundation

enum TerminalActivator {
    private static let terminalBundleIDs: Set<String> = [
        "com.mitchellh.ghostty",
        "com.googlecode.iterm2",
        "dev.warp.Warp-Stable",
        "com.apple.Terminal",
        "net.kovidgoyal.kitty",
        "co.zeit.hyper",
        "com.github.wez.wezterm",
    ]

    @discardableResult
    static func activateSession(_ session: Session) -> Bool {
        // Find running terminal apps
        let runningApps = NSWorkspace.shared.runningApplications
        let terminals = runningApps.filter { app in
            guard let bundleID = app.bundleIdentifier else { return false }
            return terminalBundleIDs.contains(bundleID)
        }

        if terminals.isEmpty { return false }

        // Activate the first running terminal
        terminals.first?.activate()
        return true
    }
}
