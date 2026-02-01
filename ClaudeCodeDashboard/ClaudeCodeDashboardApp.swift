import SwiftUI

@main
struct ClaudeCodeDashboardApp: App {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(viewModel: viewModel)
        } label: {
            let icon = viewModel.menuBarIcon
            let count = viewModel.needsAttentionCount
            if count > 0 {
                Label("\(count)", systemImage: icon)
            } else {
                Image(systemName: icon)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
