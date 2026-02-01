import SwiftUI
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var state = DashboardState()

    private let service = StateFileService()
    private var timer: Timer?

    var menuBarIcon: String {
        let visible = state.visibleSessions.filter { !$0.isStale }
        if visible.contains(where: { $0.status == .error }) {
            return "xmark.circle.fill"
        }
        if visible.contains(where: { $0.status == .waitingInput }) {
            return "exclamationmark.circle.fill"
        }
        if visible.contains(where: { $0.status == .working }) {
            return "circle.fill"
        }
        return "circle"
    }

    init() {
        loadState()
        startPolling()
    }

    func startPolling() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.pollState()
            }
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    func hideSession(_ sessionId: String) {
        if !state.hiddenSessions.contains(sessionId) {
            state.hiddenSessions.append(sessionId)
            service.writeState(state)
        }
    }

    func unhideSession(_ sessionId: String) {
        state.hiddenSessions.removeAll { $0 == sessionId }
        service.writeState(state)
    }

    func clearAll() {
        state = DashboardState()
        service.writeState(state)
    }

    private func loadState() {
        if let loaded = service.readState() {
            state = cleanStale(loaded)
        }
    }

    private func pollState() {
        guard service.hasFileChanged() else { return }
        if let loaded = service.readState() {
            state = cleanStale(loaded)
        }
    }

    private func cleanStale(_ state: DashboardState) -> DashboardState {
        var cleaned = state
        cleaned.sessions = state.sessions.filter { !$0.isStale }
        cleaned.hiddenSessions = state.hiddenSessions.filter { id in
            cleaned.sessions.contains { $0.sessionId == id }
        }
        return cleaned
    }
}
