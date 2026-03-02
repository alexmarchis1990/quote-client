import Foundation
import Testing

@testable import QuoteApp

@MainActor
@Suite("QuoteStore")
struct QuoteStoreTests {

  // MARK: - fetchQuotes

  @Test("fetchQuotes success populates quotes and sets .loaded state")
  func fetchQuotesSuccess() async {
    let store = QuoteStore(service: makeQuoteService(fetchQuotes: { Quote.samples }))

    await store.fetchQuotes()

    #expect(store.loadingState == .loaded)
    #expect(store.quotes == Quote.samples)
  }

  @Test("fetchQuotes failure sets .error state")
  func fetchQuotesFailure() async {
    let store = QuoteStore(service: makeQuoteService(
      fetchQuotes: { throw APIError.invalidResponse }
    ))

    await store.fetchQuotes()

    guard case .error(let message) = store.loadingState else {
      Issue.record("Expected .error loading state, got \(store.loadingState)")
      return
    }
    #expect(message == APIError.invalidResponse.localizedDescription)
  }

  // MARK: - selectQuote

  @Test("selectQuote sets selectedQuote")
  func selectQuote() {
    let store = QuoteStore(service: makeQuoteService())
    let quote = Quote.samples[0]

    store.selectQuote(quote)

    #expect(store.selectedQuote == quote)
  }

  // MARK: - likeQuote

  @Test("likeQuote success updates quote in list and in selectedQuote")
  func likeQuoteSuccess() async {
    let original = Quote.samples[0]
    let liked = Quote(
      id: original.id,
      text: original.text,
      author: original.author,
      bookTitle: original.bookTitle,
      likes: original.likes + 1,
      isLiked: true,
      comments: original.comments
    )
    let store = QuoteStore(service: makeQuoteService(likeQuote: { _ in liked }))
    store.quotes = [original]
    store.selectedQuote = original

    await store.likeQuote(original)

    #expect(store.quotes.first?.isLiked == true)
    #expect(store.quotes.first?.likes == original.likes + 1)
    #expect(store.selectedQuote?.isLiked == true)
  }

  @Test("likeQuote failure sets actionError")
  func likeQuoteFailure() async {
    let quote = Quote.samples[0]
    let store = QuoteStore(service: makeQuoteService(
      likeQuote: { _ in throw APIError.networkError(URLError(.notConnectedToInternet)) }
    ))
    store.quotes = [quote]

    await store.likeQuote(quote)

    #expect(store.actionError != nil)
  }

  // MARK: - fetchComments

  @Test("fetchComments success populates comments and sets .loaded state")
  func fetchCommentsSuccess() async {
    // Use sampleComments (defined in TestHelpers) to avoid Testing.Comment ambiguity.
    let store = QuoteStore(service: makeQuoteService(fetchComments: { _ in sampleComments }))

    await store.fetchComments(for: "1")

    #expect(store.commentLoadingState == .loaded)
    #expect(store.comments == sampleComments)
  }

  @Test("fetchComments failure sets .error state on commentLoadingState")
  func fetchCommentsFailure() async {
    let store = QuoteStore(service: makeQuoteService(
      fetchComments: { _ in throw APIError.invalidResponse }
    ))

    await store.fetchComments(for: "1")

    guard case .error = store.commentLoadingState else {
      Issue.record("Expected .error commentLoadingState, got \(store.commentLoadingState)")
      return
    }
  }

  // MARK: - addComment

  @Test("addComment success appends comment to list and to selectedQuote")
  func addCommentSuccess() async {
    let quoteId = "1"
    // QuoteApp.Comment(id:userId:username:text:createdAt:) is unambiguous vs Testing.Comment
    let newComment = Comment(
      id: "new", userId: "u1", username: "tester",
      text: "Great quote!", createdAt: Date()
    )
    let store = QuoteStore(service: makeQuoteService(addComment: { _, _ in newComment }))
    store.quotes = [Quote.samples[0]]
    store.selectedQuote = Quote.samples[0]

    await store.addComment(to: quoteId, text: newComment.text)

    #expect(store.comments.contains { $0.id == newComment.id })
    #expect(store.selectedQuote?.comments.contains { $0.id == newComment.id } == true)
    #expect(store.quotes[0].comments.contains { $0.id == newComment.id } == true)
  }

  @Test("addComment failure sets actionError")
  func addCommentFailure() async {
    let store = QuoteStore(service: makeQuoteService(
      addComment: { _, _ in throw APIError.invalidResponse }
    ))

    await store.addComment(to: "1", text: "test")

    #expect(store.actionError != nil)
  }

  // MARK: - clearActionError

  @Test("clearActionError resets actionError to nil")
  func clearActionError() {
    let store = QuoteStore(service: makeQuoteService())
    store.actionError = "Something went wrong"

    store.clearActionError()

    #expect(store.actionError == nil)
  }
}
