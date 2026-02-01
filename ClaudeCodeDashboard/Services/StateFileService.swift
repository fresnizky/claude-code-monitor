import Foundation

final class StateFileService {
    static let stateFilePath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.claude/dashboard-state.json"
    }()

    private var lastModificationDate: Date?

    func hasFileChanged() -> Bool {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: Self.stateFilePath),
              let mtime = attrs[.modificationDate] as? Date else {
            return lastModificationDate != nil
        }
        if mtime != lastModificationDate {
            lastModificationDate = mtime
            return true
        }
        return false
    }

    func readState() -> DashboardState? {
        guard let data = FileManager.default.contents(atPath: Self.stateFilePath) else {
            return nil
        }
        do {
            let state = try DashboardState.decoder.decode(DashboardState.self, from: data)
            return state
        } catch {
            print("Failed to decode dashboard state: \(error)")
            return nil
        }
    }

    func writeState(_ state: DashboardState) {
        do {
            let data = try DashboardState.encoder.encode(state)
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(UUID().uuidString)
            try data.write(to: tempURL)
            let stateURL = URL(fileURLWithPath: Self.stateFilePath)
            _ = try FileManager.default.replaceItemAt(stateURL, withItemAt: tempURL)
        } catch {
            print("Failed to write dashboard state: \(error)")
        }
    }
}
