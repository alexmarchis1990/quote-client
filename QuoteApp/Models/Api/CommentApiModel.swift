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
        let date: Date
        if let createdAt {
            let formatter = ISO8601DateFormatter()
            date = formatter.date(from: createdAt) ?? Date()
        } else {
            date = Date()
        }
        return Comment(
            id: id,
            userId: userId,
            username: username,
            text: text,
            createdAt: date
        )
    }
}
