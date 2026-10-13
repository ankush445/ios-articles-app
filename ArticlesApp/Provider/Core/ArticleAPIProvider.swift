import Foundation
import Alamofire

final class ArticleAPIProvider: ArticleProviderProtocol {
    func fetchArticles(completion: @escaping (Result<[Article], Error>) -> Void) {
        let url = NetworkConfiguration.articlesURL
        AppLogger.info("Request started: \(url)")

        AF.request(url)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ArticleResponse.self) { response in
                let statusCode = response.response?.statusCode ?? 0

                switch response.result {
                case .success(let apiResponse):
                    AppLogger.info("Response \(statusCode): \(apiResponse.articles.count) articles.")
                    completion(.success(apiResponse.articles))

                case .failure(let error):
                    AppLogger.error("Response \(statusCode) failed: \(error.localizedDescription)")
                    completion(.failure(NetworkError.requestFailed(error.localizedDescription)))
                }
            }
    }
}
