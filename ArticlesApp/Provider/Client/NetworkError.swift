import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case offline
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server response could not be read."
        case .offline:
            return "You're offline. Please connect to the internet and try again."
        case .requestFailed(let message):
            return message
        }
    }
}
