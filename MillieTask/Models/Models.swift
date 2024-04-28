import Foundation

struct NewsResponseVO: Codable {
    let status: String
    let totalResults: Int
    let articles: [NewsVO]
}

struct NewsVO: Codable, Hashable {
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?

    static func == (lhs: NewsVO, rhs: NewsVO) -> Bool {
        return lhs.author == rhs.author &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.url == rhs.url &&
        lhs.urlToImage == rhs.urlToImage &&
        lhs.publishedAt == rhs.publishedAt &&
        lhs.content == rhs.content
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(author)
        hasher.combine(title)
        hasher.combine(description)
        hasher.combine(url)
        hasher.combine(urlToImage)
        hasher.combine(publishedAt)
        hasher.combine(content)
    }
}
