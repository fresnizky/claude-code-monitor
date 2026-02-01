import SwiftUI

@main
struct ClaudeCodeDashboardApp: App {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(viewModel: viewModel)
        } label: {
            Image(systemName: viewModel.menuBarIcon)
        }
        .menuBarExtraStyle(.window)
    }
}
