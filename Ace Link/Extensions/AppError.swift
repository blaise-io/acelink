import Foundation

struct AppError {
    let message: String

    init(_ message: String) {
        self.message = message
    }
}

extension AppError: LocalizedError {
    var errorDescription: String? { message }
}
