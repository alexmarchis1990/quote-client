import Foundation

struct AuthResponseApiModel: ApiModel {
    let token: String?
    let user: UserApiModel?
}
