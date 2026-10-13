import UIKit

/// Lets the visible screen choose the status bar color.
final class StatusBarNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.shadowImage = UIImage()
    }

    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}
