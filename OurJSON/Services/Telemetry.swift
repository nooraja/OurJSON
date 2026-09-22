import Foundation
import OSLog

// MARK: - Telemetry Service

final class Telemetry {
    // MARK: Shared Instance
    static let shared = Telemetry()
    // MARK: Dependencies

    private let logger = Logger(subsystem: "co.id.OurJSON", category: "workflow")
    private init() {}
    // MARK: Events

    func track(_ event: String) { logger.info("event=\(event, privacy: .public)") }
}
