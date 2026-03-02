import Testing

@testable import QuoteApp

@Suite("Quote Model")
struct QuoteModelTests {

  private let quote = Quote(
    id: "1",
    text: "Sample text",
    author: "Jane Austen",
    bookTitle: "Pride and Prejudice",
    likes: 0,
    isLiked: false,
    comments: []
  )

  @Test("attribution joins author and book title with an em-dash")
  func attribution() {
    #expect(quote.attribution == "Jane Austen — Pride and Prejudice")
  }

  @Test("commentCount is 0 when comments is empty")
  func commentCountEmpty() {
    #expect(quote.commentCount == 0)
  }

  @Test("commentCount reflects the number of comments")
  func commentCountNonEmpty() {
    // Use sampleComments from TestHelpers to avoid Testing.Comment ambiguity.
    let quoteWithComments = Quote(
      id: "1", text: "text", author: "Author", bookTitle: "Book",
      likes: 0, isLiked: false, comments: sampleComments
    )
    #expect(quoteWithComments.commentCount == sampleComments.count)
  }

  @Test(
    "attribution with different inputs produces the correct string",
    arguments: [
      ("Tolstoy", "Anna Karenina", "Tolstoy — Anna Karenina"),
      ("Dickens", "A Tale of Two Cities", "Dickens — A Tale of Two Cities"),
    ]
  )
  func attributionParameterized(author: String, bookTitle: String, expected: String) {
    let q = Quote(
      id: "x", text: "t", author: author, bookTitle: bookTitle,
      likes: 0, isLiked: false, comments: []
    )
    #expect(q.attribution == expected)
  }
}
