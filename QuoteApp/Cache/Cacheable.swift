import Foundation

protocol Cacheable: Codable, Sendable {
    var cacheId: String { get }
    static var cacheTypeId: String { get }
}

struct CacheEntry<T: Cacheable>: Codable, Sendable {
    let value: T
    let timestamp: Date
    let expiration: TimeInterval

    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > expiration
    }

    init(value: T, expiration: TimeInterval = 300) {
        self.value = value
        self.timestamp = Date()
        self.expiration = expiration
    }
}
