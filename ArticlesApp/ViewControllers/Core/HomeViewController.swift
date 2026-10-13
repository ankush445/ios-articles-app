import UIKit
import SwiftUI

final class HomeViewController: UIViewController {
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var offlineContainer: UIView!

    private let gridButton = UIButton(type: .system)
    private let searchButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    private var articleManager: ArticleManager?
    private weak var router: ArticleRouter?

    private var articles: [Article] = []
    private var displayedArticles: [Article] = []
    private var usedCache = false
    private var wasConnected = true
    private var searchText = ""

    private let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    private let offlineBanner = UILabel()
    private let searchField = UITextField()
    private var offlineHost: UIHostingController<OfflineEmptyStateView>?

    private var didStartLoading = false
    private let listHeaderStack = UIStackView()

    func configure(with manager: ArticleManager, router: ArticleRouter) {
        articleManager = manager
        self.router = router
        startLoadingIfReady()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.page
        headerView.backgroundColor = .white
        setupHeaderButtons()
        setupTableView()
        setupSearchField()
        setupMessages()
        startLoadingIfReady()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    private func setupHeaderButtons() {
        gridButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        gridButton.accessibilityLabel = "Layout"
        searchButton.accessibilityLabel = "Search"
        gridButton.addTarget(self, action: #selector(gridTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        gridButton.setImage(UIImage(systemName: "square.grid.2x2", withConfiguration: symbolConfig), for: .normal)
        searchButton.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: symbolConfig), for: .normal)
        gridButton.tintColor = .black
        searchButton.tintColor = .black

        headerView.addSubview(gridButton)
        headerView.addSubview(searchButton)

        NSLayoutConstraint.activate([
            searchButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            searchButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 36),
            searchButton.heightAnchor.constraint(equalToConstant: 36),
            gridButton.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -12),
            gridButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            gridButton.widthAnchor.constraint(equalToConstant: 36),
            gridButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = AppColors.page
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 420
        tableView.keyboardDismissMode = .onDrag
        tableView.isScrollEnabled = true
        tableView.alwaysBounceVertical = true
        tableView.delaysContentTouches = false
        offlineContainer.isUserInteractionEnabled = false
        tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: ArticleCell.identifier)

        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }

    private func setupSearchField() {
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholder = "Search articles"
        searchField.borderStyle = .none
        searchField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        searchField.layer.cornerRadius = 10
        searchField.clipsToBounds = true
        searchField.clearButtonMode = .whileEditing
        searchField.autocapitalizationType = .none
        searchField.autocorrectionType = .no
        searchField.returnKeyType = .search
        searchField.font = .preferredFont(forTextStyle: .body)
        searchField.adjustsFontForContentSizeCategory = true
        searchField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)

        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = .darkGray
        icon.contentMode = .scaleAspectFit
        let iconWrap = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 20))
        icon.frame = CGRect(x: 8, y: 0, width: 18, height: 20)
        iconWrap.addSubview(icon)
        searchField.leftView = iconWrap
        searchField.leftViewMode = .always

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        cancelButton.addTarget(self, action: #selector(cancelSearchTapped), for: .touchUpInside)

        searchField.isHidden = true
        cancelButton.isHidden = true
        headerView.addSubview(searchField)
        headerView.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            searchField.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -8),
            searchField.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            cancelButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            cancelButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
    }

    private func setupMessages() {
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        offlineBanner.font = .preferredFont(forTextStyle: .footnote)
        offlineBanner.adjustsFontForContentSizeCategory = true
        offlineBanner.textColor = AppColors.card
        offlineBanner.textAlignment = .center
        offlineBanner.numberOfLines = 0
        offlineBanner.text = "You're offline. Showing saved articles."
        offlineBanner.backgroundColor = UIColor.white.withAlphaComponent(0.7)
    }

    private func startLoadingIfReady() {
        guard articleManager != nil, isViewLoaded, !didStartLoading else { return }
        didStartLoading = true
        startConnectionObserver()
        loadArticles()
    }

    private func startConnectionObserver() {
        wasConnected = articleManager?.isConnected ?? true
        articleManager?.observeConnection { [weak self] isConnected in
            guard let self else { return }
            let cameBackOnline = isConnected && self.wasConnected == false
            self.wasConnected = isConnected
            if cameBackOnline {
                self.loadArticles()
            } else {
                self.showCurrentState()
            }
        }
    }

    @objc private func refreshPulled() {
        loadArticles()
    }

    @objc private func gridTapped() {
        tableView.setContentOffset(.zero, animated: true)
    }

    @objc private func searchTapped() {
        setSearchVisible(true)
    }

    @objc private func cancelSearchTapped() {
        searchField.text = nil
        searchText = ""
        searchField.resignFirstResponder()
        applyFilter()
        setSearchVisible(false)
        showCurrentState()
    }

    private func setSearchVisible(_ visible: Bool) {
        titleLabel.isHidden = visible
        gridButton.isHidden = visible
        searchButton.isHidden = visible
        searchField.isHidden = !visible
        cancelButton.isHidden = !visible
        if visible {
            searchField.becomeFirstResponder()
        }
    }

    @objc private func searchTextChanged() {
        searchText = searchField.text ?? ""
        applyFilter()
        showCurrentState()
    }

    private func loadArticles() {
        if articles.isEmpty {
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            offlineContainer.isHidden = true
        }

        articleManager?.fetchArticles { [weak self] result in
            guard let self else { return }
            self.loadingIndicator.stopAnimating()
            self.refreshControl.endRefreshing()

            switch result {
            case .success(let list):
                self.articles = list.articles
                self.usedCache = list.usedCache
                self.applyFilter()
            case .failure:
                self.articles = []
                self.displayedArticles = []
                self.usedCache = false
            }
            self.showCurrentState()
        }
    }

    private func applyFilter() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            displayedArticles = articles
            return
        }
        displayedArticles = articles.filter { article in
            let haystack = [
                article.displayTitle,
                article.displayBody,
                article.displayAuthor
            ].joined(separator: " ")
            return haystack.localizedCaseInsensitiveContains(query)
        }
    }

    private func showCurrentState() {
        let isConnected = articleManager?.isConnected ?? true
        updateTableHeader()

        if articles.isEmpty && !isConnected {
            showOfflineEmptyState()
            return
        }

        if articles.isEmpty {
            showMessage("No articles available.")
            return
        }

        if displayedArticles.isEmpty {
            showMessage("No articles match your search.")
            return
        }

        messageLabel.removeFromSuperview()
        offlineContainer.isHidden = true
        offlineContainer.isUserInteractionEnabled = false
        tableView.isHidden = false
        tableView.reloadData()
    }

    private func updateTableHeader() {
        if listHeaderStack.arrangedSubviews.isEmpty {
            listHeaderStack.axis = .vertical
            listHeaderStack.spacing = 8
            listHeaderStack.isLayoutMarginsRelativeArrangement = true
            listHeaderStack.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            listHeaderStack.addArrangedSubview(offlineBanner)
        }

        let isConnected = articleManager?.isConnected ?? true
        offlineBanner.isHidden = !(usedCache && !isConnected && !articles.isEmpty)

        guard !offlineBanner.isHidden else {
            tableView.tableHeaderView = nil
            return
        }

        let width = tableView.bounds.width > 0 ? tableView.bounds.width : view.bounds.width
        listHeaderStack.frame = CGRect(x: 0, y: 0, width: width, height: 1)
        let height = listHeaderStack.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        listHeaderStack.frame.size.height = max(height, 44)
        tableView.tableHeaderView = listHeaderStack
    }

    private func showOfflineEmptyState() {
        tableView.isHidden = true
        messageLabel.removeFromSuperview()
        offlineContainer.isHidden = false
        offlineContainer.isUserInteractionEnabled = true

        let content = OfflineEmptyStateView(
            systemImage: "wifi.slash",
            title: "You're offline",
            message: "Please connect to the internet and try again.",
            buttonTitle: "Retry",
            onRetry: { [weak self] in
                self?.loadArticles()
            }
        )
        embedOfflineView(content)
    }

    private func showMessage(_ text: String) {
        offlineContainer.isHidden = true
        tableView.isHidden = true
        messageLabel.text = text
        if messageLabel.superview == nil {
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(messageLabel)
            NSLayoutConstraint.activate([
                messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                messageLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
            ])
        }
    }

    private func embedOfflineView(_ content: OfflineEmptyStateView) {
        if let offlineHost {
            offlineHost.rootView = content
            return
        }

        let host = UIHostingController(rootView: content)
        host.view.backgroundColor = .clear
        addChild(host)
        offlineContainer.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: offlineContainer.leadingAnchor, constant: 24),
            host.view.trailingAnchor.constraint(equalTo: offlineContainer.trailingAnchor, constant: -24),
            host.view.centerYAnchor.constraint(equalTo: offlineContainer.centerYAnchor)
        ])
        host.didMove(toParent: self)
        offlineHost = host
    }

    private func openArticleDetail(_ article: Article) {
        router?.showArticle(article)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedArticles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.identifier, for: indexPath) as? ArticleCell else {
            return UITableViewCell()
        }

        let article = displayedArticles[indexPath.row]
        cell.configure(with: article)
        cell.onReadMore = { [weak self] in
            self?.openArticleDetail(article)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openArticleDetail(displayedArticles[indexPath.row])
    }
}
