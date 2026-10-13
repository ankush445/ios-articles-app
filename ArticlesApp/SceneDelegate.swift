import UIKit
import Swinject

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var splitViewController: ArticleSplitViewController?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = self.window ?? UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        self.window = window

        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let manager = appDelegate.container.resolve(ArticleManager.self)
        else {
            fatalError("ArticleManager is not registered.")
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let home = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            fatalError("HomeViewController is missing from Main.storyboard.")
        }
        home.configure(with: manager, router: self)

        let navigation = StatusBarNavigationController(rootViewController: home)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.view.backgroundColor = AppColors.page

        let split = ArticleSplitViewController()
        split.setViewController(navigation, for: .primary)
        split.setViewController(EmptyDetailViewController(), for: .secondary)
        splitViewController = split

        window.rootViewController = SplitTouchHostController(split: split)
        window.makeKeyAndVisible()
    }
}

extension SceneDelegate: ArticleRouter {
    func showArticle(_ article: Article) {
        splitViewController?.showArticle(article)
    }
}
