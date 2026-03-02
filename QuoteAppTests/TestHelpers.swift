// This file intentionally does NOT import Testing so that `Comment` and other
// QuoteApp types are unambiguous here and in any closure passed into these helpers.
import Foundation

@testable import QuoteApp

// MARK: - Fixtures

/// Pre-built sample comments — use this instead of `Comment.samples` in test
/// files that also import Testing (where `Comment` would be ambiguous).
let sampleComments: [Comment] = Comment.samples

// MARK: - Service factories

func makeQuoteService(
  fetchQuotes: @Sendable @escaping () async throws -> [Quote] = { [] },
  likeQuote: @Sendable @escaping (_ id: String) async throws -> Quote = { _ in
    throw APIError.invalidResponse
  },
  fetchComments: @Sendable @escaping (_ quoteId: String) async throws -> [Comment] = { _ in [] },
  addComment: @Sendable @escaping (_ quoteId: String, _ text: String) async throws -> Comment = {
    _, _ in throw APIError.invalidResponse
  }
) -> QuoteService {
  QuoteService(
    fetchQuotes: fetchQuotes,
    fetchQuote: { _ in throw APIError.invalidResponse },
    likeQuote: likeQuote,
    fetchComments: fetchComments,
    addComment: addComment,
    createQuote: { _, _, _ in throw APIError.invalidResponse }
  )
}

func makeAuthService(
  login: @Sendable @escaping (_ email: String, _ password: String) async throws -> User = {
    _, _ in throw APIError.invalidResponse
  },
  signup: @Sendable @escaping (
    _ email: String, _ password: String, _ username: String
  ) async throws -> User = { _, _, _ in throw APIError.invalidResponse },
  logout: @Sendable @escaping () async throws -> Void = {},
  getCurrentUser: @Sendable @escaping () async throws -> User = {
    throw APIError.invalidResponse
  }
) -> AuthService {
  AuthService(login: login, signup: signup, logout: logout, getCurrentUser: getCurrentUser)
}
