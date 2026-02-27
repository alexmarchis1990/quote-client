import Foundation

actor TieredCache {
    private let memory: MemoryCache
    private let disk: DiskCache

    init(memory: MemoryCache = MemoryCache(), disk: DiskCache = DiskCache()) {
        self.memory = memory
        self.disk = disk
    }

    func get<T: Cacheable>(_ type: T.Type, forKey key: String) async -> T? {
        // Check memory first
        if let entry = await memory.get(type, forKey: key), !entry.isExpired {
            return entry.value
        }

        // Fall back to disk, promote to memory
        if let entry = disk.get(type, forKey: key), !entry.isExpired {
            await memory.set(entry, forKey: key)
            return entry.value
        }

        return nil
    }

    func set<T: Cacheable>(_ value: T, forKey key: String, expiration: TimeInterval = 300) async {
        let entry = CacheEntry(value: value, expiration: expiration)
        await memory.set(entry, forKey: key)
        disk.set(entry, forKey: key)
    }

    func remove<T: Cacheable>(_ type: T.Type, forKey key: String) async {
        await memory.remove(forKey: key, typeId: T.cacheTypeId)
        disk.remove(forKey: key, typeId: T.cacheTypeId)
    }

    func clear() async {
        await memory.clear()
        disk.clear()
    }
}
