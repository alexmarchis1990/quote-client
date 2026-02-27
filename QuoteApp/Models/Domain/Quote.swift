import Foundation

struct Quote: DomainModel, Cacheable {
    let id: String
    let text: String
    let author: String
    let bookTitle: String
    var likes: Int
    var isLiked: Bool
    var comments: [Comment]

    var cacheId: String { id }
    static var cacheTypeId: String { "quote" }

    var commentCount: Int { comments.count }

    var attribution: String { "\(author) — \(bookTitle)" }
}
