import Foundation
import OSLog

public extension Logger {
    init(_ category: String) {
        self = Logger(subsystem: Bundle.main.bundleIdentifier!, category: category)
    }
}
