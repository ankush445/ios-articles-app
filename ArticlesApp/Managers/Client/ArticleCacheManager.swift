import Foundation
import Cache

/// Saves the last successful article list with the Cache pod.
final class ArticleCacheManager {
    private let storage: Storage<String, [Article]>?
    private let cacheKey = "articles"

    init() {
        let diskConfig = DiskConfig(name: "Articles")
        let memoryConfig = MemoryConfig(expiry: .never)
        storage = try? Storage<String, [Article]>(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: [Article].self)
        )
        if storage == nil {
            AppLogger.error("Article cache could not be created.")
        }
    }

    func save(_ articles: [Article]) {
        do {
            try storage?.setObject(articles, forKey: cacheKey)
            AppLogger.info("Saved \(articles.count) articles to cache.")
        } catch {
            AppLogger.error("Cache save failed: \(error.localizedDescription)")
        }
    }

    func load() -> [Article]? {
        do {
            let articles = try storage?.object(forKey: cacheKey)
            if let articles {
                AppLogger.info("Loaded \(articles.count) articles from cache.")
            }
            return articles
        } catch {
            AppLogger.debug("No cached articles: \(error.localizedDescription)")
            return nil
        }
    }
}
