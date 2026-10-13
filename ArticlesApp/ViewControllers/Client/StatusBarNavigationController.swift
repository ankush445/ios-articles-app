import UIKit

/// Lets the visible screen choose the status bar color.
final class StatusBarNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}
