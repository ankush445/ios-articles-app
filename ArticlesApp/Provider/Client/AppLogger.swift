import XCGLogger

/// Shared logger for network requests, responses, and errors.
enum AppLogger {
    private static let log = XCGLogger.default

    static func configure() {
        log.setup(
            level: .debug,
            showLogIdentifier: false,
            showFunctionName: true,
            showThreadName: false,
            showLevel: true,
            showFileNames: true,
            showLineNumbers: true,
            showDate: true,
            writeToFile: nil,
            fileLevel: .debug
        )
    }

    static func debug(_ message: String) {
        log.debug(message)
    }

    static func info(_ message: String) {
        log.info(message)
    }

    static func warning(_ message: String) {
        log.warning(message)
    }

    static func error(_ message: String) {
        log.error(message)
    }
}
