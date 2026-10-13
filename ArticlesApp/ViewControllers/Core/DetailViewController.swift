import UIKit
import SafariServices

final class DetailViewController: UIViewController {
    var article: Article!

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = UIView()
    private let backButton = UIButton(type: .system)
    private let screenTitleLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let timeIcon = UIImageView()
    private let timeLabel = UILabel()
    private let articleImageView = UIImageView()
    private let bodyLabel = UILabel()
    private let readButton = UIButton(type: .system)
    private var isFavorite = false
    private var navTopConstraint: NSLayoutConstraint?

    private var showsSideBySide: Bool {
        (splitViewController as? ArticleSplitViewController)?.showsSideBySide ?? false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.card
        setupLayout()
        showArticle()
    }



    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        navTopConstraint?.constant = view.safeAreaInsets.top + 8
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backButton.isHidden = showsSideBySide
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        showsSideBySide ? .darkContent : .lightContent
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = AppColors.detailPage
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        contentView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = AppColors.card

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        setupHeader()
        setupBody()
    }

    private func setupHeader() {
        AppButtons.applyChromeStyle(
            to: backButton,
            symbolName: "chevron.left",
            foreground: AppColors.card,
            fallbackFill: UIColor.white.withAlphaComponent(0.92)
        )
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.accessibilityLabel = "Back"
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.layer.shadowOpacity = 0
        backButton.layer.shadowRadius = 0

        screenTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        screenTitleLabel.text = "Article"
        screenTitleLabel.textColor = .white
        screenTitleLabel.font = .preferredFont(forTextStyle: .headline)
        screenTitleLabel.adjustsFontForContentSizeCategory = true
        screenTitleLabel.textAlignment = .center

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.accessibilityLabel = "Save article"
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        updateFavoriteButton()

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        titleLabel.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: .systemFont(ofSize: 28, weight: .bold))
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0

        timeIcon.translatesAutoresizingMaskIntoConstraints = false
        timeIcon.image = UIImage(systemName: "clock")
        timeIcon.tintColor = AppColors.dateOnCard
        timeIcon.contentMode = .scaleAspectFit

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textColor = AppColors.dateOnCard
        timeLabel.font = .preferredFont(forTextStyle: .subheadline)
        timeLabel.adjustsFontForContentSizeCategory = true

        articleImageView.translatesAutoresizingMaskIntoConstraints = false
        articleImageView.clipsToBounds = true
        articleImageView.layer.cornerRadius = 16

        headerView.addSubview(backButton)
        headerView.addSubview(screenTitleLabel)
        headerView.addSubview(favoriteButton)
        headerView.addSubview(titleLabel)
        headerView.addSubview(timeIcon)
        headerView.addSubview(timeLabel)

        let navTop = backButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8)
        navTopConstraint = navTop

        NSLayoutConstraint.activate([
            navTop,
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            favoriteButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            favoriteButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            favoriteButton.heightAnchor.constraint(equalToConstant: 40),

            screenTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            screenTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            screenTitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
            screenTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: favoriteButton.leadingAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),

            timeIcon.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeIcon.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            timeIcon.widthAnchor.constraint(equalToConstant: 18),
            timeIcon.heightAnchor.constraint(equalToConstant: 18),

            timeLabel.leadingAnchor.constraint(equalTo: timeIcon.trailingAnchor, constant: 8),
            timeLabel.centerYAnchor.constraint(equalTo: timeIcon.centerYAnchor),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -20)
        ])
    }

    private func setupBody() {
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.textColor = AppColors.body
        bodyLabel.font = .preferredFont(forTextStyle: .body)
        bodyLabel.adjustsFontForContentSizeCategory = true
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .byWordWrapping

        var readConfig = UIButton.Configuration.filled()
        readConfig.title = "Read full article"
        readConfig.baseBackgroundColor = AppColors.accent
        readConfig.baseForegroundColor = .white
        readConfig.cornerStyle = .medium
        readButton.configuration = readConfig
        readButton.translatesAutoresizingMaskIntoConstraints = false
        readButton.addTarget(self, action: #selector(readFullArticleTapped), for: .touchUpInside)

        contentView.addSubview(articleImageView)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(readButton)

        NSLayoutConstraint.activate([
            articleImageView.topAnchor.constraint(equalTo: timeIcon.bottomAnchor, constant: 18),
            articleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            articleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            articleImageView.heightAnchor.constraint(equalTo: articleImageView.widthAnchor, multiplier: 0.62),
            headerView.bottomAnchor.constraint(equalTo: articleImageView.centerYAnchor),

            bodyLabel.topAnchor.constraint(equalTo: articleImageView.bottomAnchor, constant: 20),
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            readButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 24),
            readButton.leadingAnchor.constraint(equalTo: bodyLabel.leadingAnchor),
            readButton.trailingAnchor.constraint(equalTo: bodyLabel.trailingAnchor),
            readButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            readButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    private func showArticle() {
        titleLabel.text = article.displayTitle
        timeLabel.text = article.relativeTime
        bodyLabel.text = article.content
        articleImageView.setArticleImage(url: article.imageURL)
        articleImageView.layer.cornerRadius = 16

        if article.articleURL == nil {
            readButton.isEnabled = false
            var config = readButton.configuration
            config?.title = "Full article link unavailable"
            readButton.configuration = config
        }
    }

    private func updateFavoriteButton() {
        let symbolName = isFavorite ? "heart.fill" : "heart.badge.plus"
        let image = UIImage(systemName: symbolName) ?? UIImage(systemName: "heart")
        var config = UIButton.Configuration.plain()
        config.image = image
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        config.baseForegroundColor = .white
        favoriteButton.configuration = config
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func favoriteTapped() {
        isFavorite.toggle()
        updateFavoriteButton()
    }

    @objc private func readFullArticleTapped() {
        guard let url = article.articleURL else { return }
        present(SFSafariViewController(url: url), animated: true)
    }
}
