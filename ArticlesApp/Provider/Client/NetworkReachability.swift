import Foundation
import Reachability

/// Wraps ReachabilitySwift so the rest of the app does not talk to the pod directly.
final class NetworkReachability {
    private let reachability: Reachability?
    var onStatusChange: ((Bool) -> Void)?

    init() {
        reachability = try? Reachability()
        reachability?.whenReachable = { [weak self] _ in
            self?.onStatusChange?(true)
        }
        reachability?.whenUnreachable = { [weak self] _ in
            self?.onStatusChange?(false)
        }
    }

    var isConnected: Bool {
        guard let reachability else { return true }
        return reachability.connection != .unavailable
    }

    func start() {
        do {
            try reachability?.startNotifier()
        } catch {
            AppLogger.error("Reachability failed to start: \(error.localizedDescription)")
        }
    }
}
