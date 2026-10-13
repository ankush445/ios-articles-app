import UIKit
import Swinject

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let container = Container()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        AppLogger.configure()
        registerDependencies()
        return true
    }

    private func registerDependencies() {
        container.register(ArticleProviderProtocol.self) { _ in
            ArticleAPIProvider()
        }.inObjectScope(.container)

        container.register(ArticleCacheManager.self) { _ in
            ArticleCacheManager()
        }.inObjectScope(.container)

        container.register(NetworkReachability.self) { _ in
            NetworkReachability()
        }.inObjectScope(.container)

        container.register(ArticleManager.self) { resolver in
            guard
                let provider = resolver.resolve(ArticleProviderProtocol.self),
                let cache = resolver.resolve(ArticleCacheManager.self),
                let reachability = resolver.resolve(NetworkReachability.self)
            else {
                fatalError("Article dependencies are not registered.")
            }
            return ArticleManager(provider: provider, cache: cache, reachability: reachability)
        }.inObjectScope(.container)
    }
}
