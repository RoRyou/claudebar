import SwiftUI
import Observation

@Observable
class UsageModel {
    var session: Int = 0
    var extra: Int = 0
    var resetTime: String = "--"
    var lastUpdated: Date? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private var timer: Timer?
    private let interval: TimeInterval = 30

    init() {
        startTimer()
        Task { await refresh() }
    }

    @MainActor
    func refresh() async {
        isLoading = true
        errorMessage = nil
        do {
            let data = try await ClaudeRunner.fetchUsage()
            session     = data.session
            extra       = data.extra
            resetTime   = data.resetTime
            lastUpdated = Date()
            isLoading   = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading    = false
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { await self?.refresh() }
        }
    }

    var lastUpdatedString: String {
        guard let d = lastUpdated else { return "Never" }
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: d, relativeTo: Date())
    }
}
