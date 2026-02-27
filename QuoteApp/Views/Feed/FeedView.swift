import SwiftUI

private let feedSpacing: CGFloat = 16
private let feedNavigationTitle = "Quote"

struct FeedView: View {
    @Environment(\.quoteService) private var quoteService
    @State private var store: QuoteStore?

    var body: some View {
        Group {
            if let store {
                LoadingStateView(state: store.loadingState) {
                    feedContent(store: store)
                }
            } else {
                ProgressView()
                    .accessibilityLabel("Loading feed")
            }
        }
        .navigationTitle(feedNavigationTitle)
        .task {
            if store == nil {
                store = QuoteStore(service: quoteService)
            }
            await store?.fetchQuotes()
        }
    }

    @ViewBuilder
    private func feedContent(store: QuoteStore) -> some View {
        ScrollView {
            LazyVStack(spacing: feedSpacing) {
                ForEach(store.quotes) { quote in
                    NavigationLink(value: Screen.quote(.detail(quote))) {
                        QuoteCardView(
                            quote: quote,
                            onLike: { Task { await store.likeQuote(quote) } }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .refreshable {
            await store.fetchQuotes()
        }
        .accessibilityLabel("Quote feed")
    }
}

#Preview {
    NavigationStack {
        FeedView()
            .screenDestination()
    }
    .environment(\.quoteService, .mock)
}
