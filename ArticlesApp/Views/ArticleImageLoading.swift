import UIKit
import Kingfisher

extension UIImageView {
    /// Loads an article image with Kingfisher. A missing or failed image shows the placeholder asset.
    func setArticleImage(url: URL?) {
        kf.cancelDownloadTask()
        clipsToBounds = true
        contentMode = .scaleAspectFill
        layer.cornerRadius = AppMetrics.imageCornerRadius
        backgroundColor = .clear

        let placeholder = UIImage(named: "placeholder")
        guard let url else {
            image = placeholder
            return
        }

        kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.25))]
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success:
                    self.contentMode = .scaleAspectFill
                case .failure(let error):
                    AppLogger.warning("Image failed: \(error.localizedDescription)")
                    self.contentMode = .scaleAspectFill
                    self.image = placeholder
                }
            }
        }
    }
}
