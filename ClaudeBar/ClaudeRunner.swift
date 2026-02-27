import Foundation

struct UsageData {
    var session: Int      // 0–100
    var extra: Int        // 0–100
    var resetTime: String // e.g. "5:59pm"
}

enum ClaudeRunnerError: Error {
    case fileNotFound
    case parseFailure
    case staleData
}

struct ClaudeRunner {
    static let cacheFile = "/tmp/claudebar-usage.json"

    static func fetchUsage() async throws -> UsageData {
        guard FileManager.default.fileExists(atPath: cacheFile) else {
            throw ClaudeRunnerError.fileNotFound
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: cacheFile))
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ClaudeRunnerError.parseFailure
        }

        // Reject data older than 10 minutes
        if let ts = json["timestamp"] as? Double {
            if Date().timeIntervalSince1970 - ts > 600 {
                throw ClaudeRunnerError.staleData
            }
        }

        return UsageData(
            session:   json["session"]   as? Int    ?? 0,
            extra:     json["extra"]     as? Int    ?? 0,
            resetTime: json["reset"]     as? String ?? "--"
        )
    }
}
