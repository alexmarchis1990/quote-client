import Foundation

struct CreateQuoteBody: Encodable {
    let text: String
    let author: String
    let bookId: String?
}
