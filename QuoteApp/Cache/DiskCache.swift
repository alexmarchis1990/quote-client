import Foundation

struct DiskCache: Sendable {
    private let directory: URL

    init(directory: String = "QuoteAppCache") {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.directory = caches.appendingPathComponent(directory)
        try? FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    func get<T: Cacheable>(_ type: T.Type, forKey key: String) -> CacheEntry<T>? {
        let fileURL = fileURL(for: key, typeId: T.cacheTypeId)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(CacheEntry<T>.self, from: data)
    }

    func set<T: Cacheable>(_ entry: CacheEntry<T>, forKey key: String) {
        let fileURL = fileURL(for: key, typeId: T.cacheTypeId)
        guard let data = try? JSONEncoder().encode(entry) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func remove(forKey key: String, typeId: String) {
        let fileURL = fileURL(for: key, typeId: typeId)
        try? FileManager.default.removeItem(at: fileURL)
    }

    func clear() {
        try? FileManager.default.removeItem(at: directory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    private func fileURL(for key: String, typeId: String) -> URL {
        let sanitized = "\(typeId)_\(key)".addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key
        return directory
            .appendingPathComponent(sanitized)
            .appendingPathExtension("json")
    }
}
