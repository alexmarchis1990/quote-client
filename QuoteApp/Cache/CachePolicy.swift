import Foundation

enum CachePolicy: Sendable {
    /// Always fetch from network, ignore cache
    case networkOnly
    /// Return cache if available, then fetch and update
    case cacheThenFetch
    /// Return cache if available and not expired, otherwise fetch
    case cacheElseFetch
    /// Only return cache, never fetch
    case cacheOnly
    /// Fetch from network, fall back to cache on error
    case fetchElseCache
}
