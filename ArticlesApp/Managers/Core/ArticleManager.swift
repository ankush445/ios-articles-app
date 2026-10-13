import Foundation

/// What the home screen receives after a fetch.
struct ArticleListResult {
    let articles: [Article]
    /// True when the list came from disk because the network was unavailable or failed.
    let usedCache: Bool
}

/// The only type view controllers use to load articles.
/// It hides networking, caching, and connectivity.
final class ArticleManager {
    private let provider: ArticleProviderProtocol
    private let cache: ArticleCacheManager
    private let reachability: NetworkReachability

    init(
        provider: ArticleProviderProtocol,
        cache: ArticleCacheManager,
        reachability: NetworkReachability
    ) {
        self.provider = provider
        self.cache = cache
        self.reachability = reachability
        reachability.start()
    }

    var isConnected: Bool {
        reachability.isConnected
    }

    func observeConnection(_ handler: @escaping (Bool) -> Void) {
        reachability.onStatusChange = { isConnected in
            DispatchQueue.main.async {
                handler(isConnected)
            }
        }
    }

    func fetchArticles(completion: @escaping (Result<ArticleListResult, Error>) -> Void) {
        if !isConnected {
            deliver(cachedOrOffline(), completion: completion)
            return
        }

        provider.fetchArticles { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let articles):
                self.cache.save(articles)
                self.deliver(.success(ArticleListResult(articles: articles, usedCache: false)), completion: completion)

            case .failure(let error):
                if let cached = self.cache.load() {
                    self.deliver(.success(ArticleListResult(articles: cached, usedCache: true)), completion: completion)
                } else {
                    self.deliver(.failure(error), completion: completion)
                }
            }
        }
    }

    private func cachedOrOffline() -> Result<ArticleListResult, Error> {
        if let cached = cache.load() {
            return .success(ArticleListResult(articles: cached, usedCache: true))
        }
        return .failure(NetworkError.offline)
    }

    private func deliver(
        _ result: Result<ArticleListResult, Error>,
        completion: @escaping (Result<ArticleListResult, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
