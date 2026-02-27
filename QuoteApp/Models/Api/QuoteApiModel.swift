import Foundation

struct QuoteApiModel: ApiModel {
    let id: String?
    let text: String?
    let author: String?
    let bookTitle: String?
    let likes: Int?
    let isLiked: Bool?
    let comments: [CommentApiModel]?
}

extension QuoteApiModel {
    var domainModel: Quote? {
        guard let id, let text, let author, let bookTitle else { return nil }
        return Quote(
            id: id,
            text: text,
            author: author,
            bookTitle: bookTitle,
            likes: likes ?? 0,
            isLiked: isLiked ?? false,
            comments: comments?.compactMap(\.domainModel) ?? []
        )
    }
}
