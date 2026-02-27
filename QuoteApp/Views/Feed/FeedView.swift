import SwiftUI

private let feedSpacing: CGFloat = 16
private let feedNavigationTitle = "Quote"

struct FeedView: View {
    @Environment(QuoteStore.self) private var store

    var body: some View {
        LoadingStateView(state: store.loadingState) {
            feedContent
        }
        .navigationTitle(feedNavigationTitle)
        .task {
            await store.fetchQuotes()
        }
        .alert("Action Failed", isPresented: Binding(
            get: { store.actionError != nil },
            set: { if !$0 { store.clearActionError() } }
        )) {
            Button("OK", role: .cancel) { store.clearActionError() }
        } message: {
            Text(store.actionError ?? "")
        }
    }

    private var feedContent: some View {
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
    .environment(QuoteStore(service: .mock))
    .environment(\.quoteService, .mock)
}
