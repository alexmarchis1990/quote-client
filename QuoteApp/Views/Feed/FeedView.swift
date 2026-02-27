import SwiftUI

struct FeedView: View {
    @Environment(\.quoteService) private var quoteService
    @State private var store: QuoteStore?

    var body: some View {
        Group {
            if let store {
                LoadingStateView(state: store.loadingState) {
                    ScrollView {
                        LazyVStack(spacing: 16) {
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
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Quote")
        .task {
            if store == nil {
                store = QuoteStore(service: quoteService)
            }
            await store?.fetchQuotes()
        }
    }
}

#Preview {
    NavigationStack {
        FeedView()
            .screenDestination()
    }
    .environment(\.quoteService, .mock)
}
