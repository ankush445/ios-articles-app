import UIKit
import Kingfisher

final class ArticleCell: UITableViewCell {
    static let identifier = "ArticleCell"

    @IBOutlet private weak var articleView: UIView!
    @IBOutlet private weak var articleImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var calendarImageView: UIImageView!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var readMoreContainer: UIView!
    @IBOutlet private weak var readMoreLabel: UILabel!
    @IBOutlet private weak var readMoreButton: UIButton!

    var onReadMore: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = AppColors.page

        articleView.backgroundColor = AppColors.card
        articleView.layer.cornerRadius = AppMetrics.cardCornerRadius
        articleView.clipsToBounds = true

        titleLabel.textColor = .white
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0

        dateLabel.textColor = AppColors.dateOnCard
        dateLabel.font = .preferredFont(forTextStyle: .subheadline)
        dateLabel.adjustsFontForContentSizeCategory = true

        calendarImageView.image = UIImage(named: "calendar")?.withRenderingMode(.alwaysTemplate)
        calendarImageView.tintColor = AppColors.dateOnCard
        arrowImageView.image = UIImage(named: "arrow")?.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = .white

        readMoreContainer.backgroundColor = AppColors.accent
        readMoreContainer.layer.cornerRadius = AppMetrics.buttonCornerRadius
        readMoreLabel.textColor = .white
        readMoreLabel.font = .preferredFont(forTextStyle: .subheadline)
        readMoreLabel.adjustsFontForContentSizeCategory = true

        readMoreButton.setTitle(nil, for: .normal)
        readMoreButton.configuration = nil
        readMoreButton.isExclusiveTouch = false
    }

    func configure(with article: Article) {
        titleLabel.text = article.displayTitle
        dateLabel.text = article.formattedDate
        articleImageView.setArticleImage(url: article.imageURL)
    }

    @IBAction private func readMoreTapped(_ sender: UIButton) {
        onReadMore?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        articleImageView.kf.cancelDownloadTask()
        articleImageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
        onReadMore = nil
    }
}
