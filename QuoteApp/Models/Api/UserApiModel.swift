import Foundation

struct UserApiModel: ApiModel {
    let id: String?
    let email: String?
    let username: String?
}

extension UserApiModel {
    var domainModel: User? {
        guard let id, let email else { return nil }
        return User(
            id: id,
            email: email,
            username: username ?? ""
        )
    }
}
