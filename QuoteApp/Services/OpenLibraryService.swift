import Foundation

struct OpenLibraryBook: Identifiable {
    let id: String
    let title: String
    let authorName: String
}

private struct OpenLibrarySearchResponse: Decodable {
    let docs: [OpenLibraryDoc]
}

private struct OpenLibraryDoc: Decodable {
    let key: String?
    let title: String?
    let authorName: [String]?

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorName = "author_name"
    }
}

enum OpenLibraryService {
    private static let baseURL = URL(string: "https://openlibrary.org/search.json")!

    static func searchBooks(query: String, limit: Int = 10) async throws -> [OpenLibraryBook] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "q", value: query.trimmingCharacters(in: .whitespacesAndNewlines)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        guard let url = components.url else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)
        return response.docs.compactMap { doc -> OpenLibraryBook? in
            guard let key = doc.key, let title = doc.title, !title.isEmpty else { return nil }
            let authorName = doc.authorName?.joined(separator: ", ") ?? ""
            let id = key.replacingOccurrences(of: "/works/", with: "")
            return OpenLibraryBook(id: id, title: title, authorName: authorName)
        }
    }
}
