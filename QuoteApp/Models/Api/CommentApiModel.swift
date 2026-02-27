import Foundation

struct CommentApiModel: ApiModel {
    let id: String?
    let userId: String?
    let username: String?
    let text: String?
    let createdAt: String?
}

extension CommentApiModel {
    var domainModel: Comment? {
        guard let id, let userId, let username, let text else { return nil }
        let formatter = ISO8601DateFormatter()
        let date = createdAt.flatMap { formatter.date(from: $0) } ?? Date()
        return Comment(
            id: id,
            userId: userId,
            username: username,
            text: text,
            createdAt: date
        )
    }
}
