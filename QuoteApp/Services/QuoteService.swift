import Foundation
import SwiftUI

struct QuoteService: Sendable {
    var fetchQuotes: @Sendable () async throws -> [Quote]
    var fetchQuote: @Sendable (_ id: String) async throws -> Quote
    var likeQuote: @Sendable (_ id: String) async throws -> Quote
    var fetchComments: @Sendable (_ quoteId: String) async throws -> [Comment]
    var addComment: @Sendable (_ quoteId: String, _ text: String) async throws -> Comment
    var createQuote: @Sendable (_ text: String, _ author: String, _ bookId: String?) async throws -> Quote
}

// MARK: - Live

extension QuoteService {
    static func live(client: APIClient = APIClient()) -> QuoteService {
        QuoteService(
            fetchQuotes: {
                let apiModels: [QuoteApiModel] = try await client.get("/quotes")
                return apiModels.compactMap(\.domainModel)
            },
            fetchQuote: { id in
                let apiModel: QuoteApiModel = try await client.get("/quotes/\(id)")
                guard let quote = apiModel.domainModel else { throw APIError.decodingError }
                return quote
            },
            likeQuote: { id in
                let apiModel: QuoteApiModel = try await client.post("/quotes/\(id)/like")
                guard let quote = apiModel.domainModel else { throw APIError.decodingError }
                return quote
            },
            fetchComments: { quoteId in
                let apiModels: [CommentApiModel] = try await client.get("/quotes/\(quoteId)/comments")
                return apiModels.compactMap(\.domainModel)
            },
            addComment: { quoteId, text in
                let body = ["text": text]
                let apiModel: CommentApiModel = try await client.post("/quotes/\(quoteId)/comments", body: body)
                guard let comment = apiModel.domainModel else { throw APIError.decodingError }
                return comment
            },
            createQuote: { text, author, bookId in
                let body = CreateQuoteBody(text: text, author: author, bookId: bookId)
                let apiModel: QuoteApiModel = try await client.post("/quotes", body: body)
                guard let quote = apiModel.domainModel else { throw APIError.decodingError }
                return quote
            }
        )
    }
}

// MARK: - Mock

extension QuoteService {
    static let mock = QuoteService(
        fetchQuotes: {
            try? await Task.sleep(for: .milliseconds(500))
            return Quote.samples
        },
        fetchQuote: { id in
            try? await Task.sleep(for: .milliseconds(300))
            guard let quote = Quote.samples.first(where: { $0.id == id }) else {
                throw APIError.invalidResponse
            }
            return quote
        },
        likeQuote: { id in
            try? await Task.sleep(for: .milliseconds(200))
            guard var quote = Quote.samples.first(where: { $0.id == id }) else {
                throw APIError.invalidResponse
            }
            quote.isLiked.toggle()
            quote.likes += quote.isLiked ? 1 : -1
            return quote
        },
        fetchComments: { _ in
            try? await Task.sleep(for: .milliseconds(300))
            return Comment.samples
        },
        addComment: { _, text in
            try? await Task.sleep(for: .milliseconds(200))
            return Comment(
                id: UUID().uuidString,
                userId: "currentUser",
                username: "You",
                text: text,
                createdAt: Date()
            )
        },
        createQuote: { text, author, bookId in
            try? await Task.sleep(for: .milliseconds(300))
            return Quote(
                id: UUID().uuidString,
                text: text,
                author: author,
                bookTitle: bookId ?? "Unknown",
                likes: 0,
                isLiked: false,
                comments: []
            )
        }
    )
}

// MARK: - Preview

extension QuoteService {
    static let preview = mock
}

// MARK: - Unimplemented

extension QuoteService {
    static let unimplemented = QuoteService(
        fetchQuotes: { fatalError("fetchQuotes not implemented") },
        fetchQuote: { _ in fatalError("fetchQuote not implemented") },
        likeQuote: { _ in fatalError("likeQuote not implemented") },
        fetchComments: { _ in fatalError("fetchComments not implemented") },
        addComment: { _, _ in fatalError("addComment not implemented") },
        createQuote: { _, _, _ in fatalError("createQuote not implemented") }
    )
}

// MARK: - Environment

extension EnvironmentValues {
    @Entry var quoteService: QuoteService = .unimplemented
}

// MARK: - Sample Data

extension Quote {
    static let samples: [Quote] = [
        Quote(
            id: "1",
            text: "It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife.",
            author: "Jane Austen",
            bookTitle: "Pride and Prejudice",
            likes: 42,
            isLiked: false,
            comments: Comment.samples
        ),
        Quote(
            id: "2",
            text: "All happy families are alike; each unhappy family is unhappy in its own way.",
            author: "Leo Tolstoy",
            bookTitle: "Anna Karenina",
            likes: 38,
            isLiked: true,
            comments: []
        ),
        Quote(
            id: "3",
            text: "It was the best of times, it was the worst of times, it was the age of wisdom, it was the age of foolishness.",
            author: "Charles Dickens",
            bookTitle: "A Tale of Two Cities",
            likes: 56,
            isLiked: false,
            comments: []
        ),
        Quote(
            id: "4",
            text: "In the beginning the Universe was created. This has made a lot of people very angry and been widely regarded as a bad move.",
            author: "Douglas Adams",
            bookTitle: "The Restaurant at the End of the Universe",
            likes: 91,
            isLiked: true,
            comments: []
        ),
    ]
}

extension Comment {
    static let samples: [Comment] = [
        Comment(id: "c1", userId: "u1", username: "bookworm42", text: "One of the greatest opening lines in literature!", createdAt: Date().addingTimeInterval(-3600)),
        Comment(id: "c2", userId: "u2", username: "janeite", text: "Austen's wit is unmatched.", createdAt: Date().addingTimeInterval(-7200)),
        Comment(id: "c3", userId: "u3", username: "reader_sam", text: "This never gets old.", createdAt: Date().addingTimeInterval(-86400)),
    ]
}
