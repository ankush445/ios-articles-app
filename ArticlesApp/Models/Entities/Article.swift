import Foundation

struct ArticleSource: Codable {
    let id: String?
    let name: String?
}

struct Article: Codable {
    let source: ArticleSource?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?

    var displayTitle: String {
        let value = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? "Untitled Article" : value
    }

    var displayAuthor: String {
        let value = author?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? "Unknown Author" : value
    }

    /// Description, then content, so a missing field still leaves something to read.
    var displayBody: String {
        let descriptionText = cleaned(description)
        let contentText = cleaned(content)
        if let descriptionText { return descriptionText }
        if let contentText { return contentText }
        return "Article content is not available."
    }

    var imageURL: URL? {
        validURL(from: urlToImage)
    }

    var articleURL: URL? {
        validURL(from: url)
    }

    /// Example: 24 Oct,2021
    var formattedDate: String {
        guard let date = parsedDate else { return "Date unavailable" }
        return ArticleDateFormat.list.string(from: date)
    }

    /// Example: 10h ago
    var relativeTime: String {
        guard let date = parsedDate else { return "Date unavailable" }
        return ArticleDateFormat.relative.localizedString(for: date, relativeTo: Date())
    }

    private var parsedDate: Date? {
        guard let publishedAt, !publishedAt.isEmpty else { return nil }
        if let date = ArticleDateFormat.isoWithFraction.date(from: publishedAt) {
            return date
        }
        return ArticleDateFormat.iso.date(from: publishedAt)
    }

    private func cleaned(_ value: String?) -> String? {
        let text = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return text.isEmpty ? nil : text
    }

    private func validURL(from rawValue: String?) -> URL? {
        guard let rawValue else { return nil }
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil else {
            return nil
        }
        return url
    }
}

/// Date formatters are reused so the list does not create one per cell.
private enum ArticleDateFormat {
    static let isoWithFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let iso: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static let list: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM,yyyy"
        return formatter
    }()

    static let relative: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
}
