import Foundation

actor MemoryCache {
    private var storage: [String: Any] = [:]
    private var accessOrder: [String] = []
    private let maxEntries: Int

    init(maxEntries: Int = 100) {
        self.maxEntries = maxEntries
    }

    func get<T: Cacheable>(_ type: T.Type, forKey key: String) -> CacheEntry<T>? {
        let fullKey = "\(T.cacheTypeId):\(key)"
        guard let entry = storage[fullKey] as? CacheEntry<T> else { return nil }
        promoteKey(fullKey)
        return entry
    }

    func set<T: Cacheable>(_ entry: CacheEntry<T>, forKey key: String) {
        let fullKey = "\(T.cacheTypeId):\(key)"
        storage[fullKey] = entry
        promoteKey(fullKey)
        evictIfNeeded()
    }

    func remove(forKey key: String, typeId: String) {
        let fullKey = "\(typeId):\(key)"
        storage.removeValue(forKey: fullKey)
        accessOrder.removeAll { $0 == fullKey }
    }

    func clear() {
        storage.removeAll()
        accessOrder.removeAll()
    }

    private func promoteKey(_ key: String) {
        accessOrder.removeAll { $0 == key }
        accessOrder.append(key)
    }

    private func evictIfNeeded() {
        while storage.count > maxEntries, let oldest = accessOrder.first {
            storage.removeValue(forKey: oldest)
            accessOrder.removeFirst()
        }
    }
}
