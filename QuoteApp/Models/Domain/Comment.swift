import Foundation

struct Comment: DomainModel, Cacheable {
    let id: String
    let userId: String
    let username: String
    let text: String
    let createdAt: Date

    var cacheId: String { id }
    static var cacheTypeId: String { "comment" }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}
