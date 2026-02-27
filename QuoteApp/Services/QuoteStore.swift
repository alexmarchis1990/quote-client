import Foundation
import SwiftUI

enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

@MainActor
@Observable
final class QuoteStore {
    var quotes: [Quote] = []
    var selectedQuote: Quote?
    var comments: [Comment] = []
    var loadingState: LoadingState = .idle
    var commentLoadingState: LoadingState = .idle

    private let service: QuoteService

    init(service: QuoteService) {
        self.service = service
    }

    func fetchQuotes() async {
        loadingState = .loading
        do {
            quotes = try await service.fetchQuotes()
            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }

    func selectQuote(_ quote: Quote) {
        selectedQuote = quote
    }

    func likeQuote(_ quote: Quote) async {
        do {
            let updated = try await service.likeQuote(quote.id)
            if let index = quotes.firstIndex(where: { $0.id == updated.id }) {
                quotes[index] = updated
            }
            if selectedQuote?.id == updated.id {
                selectedQuote = updated
            }
        } catch {
            // Silently fail — optimistic UI could be added later
        }
    }

    func fetchComments(for quoteId: String) async {
        commentLoadingState = .loading
        do {
            comments = try await service.fetchComments(quoteId)
            commentLoadingState = .loaded
        } catch {
            commentLoadingState = .error(error.localizedDescription)
        }
    }

    func addComment(to quoteId: String, text: String) async {
        do {
            let comment = try await service.addComment(quoteId, text)
            comments.append(comment)
            if let index = quotes.firstIndex(where: { $0.id == quoteId }) {
                quotes[index].comments.append(comment)
            }
            if selectedQuote?.id == quoteId {
                selectedQuote?.comments.append(comment)
            }
        } catch {
            // Handle error if needed
        }
    }
}
