import UIKit

/// Colors and sizes taken from the article list and detail designs.
enum AppColors {
    /// White page behind the cards.
    static let page = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    /// Article card and detail header, #233D46.
    static let card = UIColor(red: 35.0 / 255.0, green: 61.0 / 255.0, blue: 70.0 / 255.0, alpha: 1)
    /// Read More button, #195A94.
    static let accent = UIColor(red: 25.0 / 255.0, green: 90.0 / 255.0, blue: 148.0 / 255.0, alpha: 1)
    /// Muted date color on a dark card.
    static let dateOnCard = UIColor(red: 0.655, green: 0.745, blue: 0.784, alpha: 1)
    /// Light gray behind the detail article text.
    static let detailPage = UIColor(white: 0.95, alpha: 1)
    /// Body text on the detail screen.
    static let body = UIColor(red: 0.420, green: 0.455, blue: 0.490, alpha: 1)
}

enum AppMetrics {
    static let cardCornerRadius: CGFloat = 18
    static let imageCornerRadius: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 12
    static let horizontalInset: CGFloat = 16
}

enum AppButtons {
    /// Liquid Glass on iOS 26. A plain filled circle on iOS 18–25.
    static func applyChromeStyle(to button: UIButton, symbolName: String, foreground: UIColor, fallbackFill: UIColor) {
        let image = UIImage(systemName: symbolName)
        if #available(iOS 26.0, *) {
            var config = UIButton.Configuration.glass()
            config.image = image
            config.baseForegroundColor = foreground
            config.cornerStyle = .capsule
            button.configuration = config
        } else {
            var config = UIButton.Configuration.filled()
            config.image = image
            config.baseForegroundColor = foreground
            config.baseBackgroundColor = fallbackFill
            config.cornerStyle = .capsule
            button.configuration = config
        }
    }
}
