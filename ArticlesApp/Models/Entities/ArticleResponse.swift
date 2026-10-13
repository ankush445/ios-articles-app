import Foundation

struct ArticleResponse: Decodable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]

    private enum CodingKeys: String, CodingKey {
        case status
        case totalResults
        case articles
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        totalResults = try container.decodeIfPresent(Int.self, forKey: .totalResults)

        // One bad article should not throw away the whole list.
        let wrapped = try container.decodeIfPresent([SafeArticle].self, forKey: .articles) ?? []
        articles = wrapped.compactMap(\.article)
    }
}

/// Decodes one article. If that object is invalid JSON, it is skipped.
private struct SafeArticle: Decodable {
    let article: Article?

    init(from decoder: Decoder) throws {
        article = try? Article(from: decoder)
    }
}
