import UIKit

/// Home screen asks this to open an article. The scene decides iPhone push vs iPad split.
protocol ArticleRouter: AnyObject {
    func showArticle(_ article: Article)
}
