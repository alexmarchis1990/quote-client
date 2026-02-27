import SwiftUI

struct QuoteDetailView: View {
    let quote: Quote
    @Environment(\.quoteService) private var quoteService
    @State private var store: QuoteStore?
    @State private var commentText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Quote content
                VStack(alignment: .leading, spacing: 12) {
                    Text(quote.text)
                        .font(.title3)
                        .italic()

                    Text(quote.attribution)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 20) {
                        Button {
                            Task { await store?.likeQuote(quote) }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: currentQuote.isLiked ? "heart.fill" : "heart")
                                    .foregroundStyle(currentQuote.isLiked ? .red : .secondary)
                                Text("\(currentQuote.likes)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Comments section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Comments")
                        .font(.headline)

                    if let store {
                        LoadingStateView(state: store.commentLoadingState) {
                            if store.comments.isEmpty {
                                Text("No comments yet. Be the first!")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            } else {
                                ForEach(store.comments) { comment in
                                    CommentView(comment: comment)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Add comment
                HStack {
                    TextField("Add a comment...", text: $commentText)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        guard !commentText.isEmpty else { return }
                        let text = commentText
                        commentText = ""
                        Task { await store?.addComment(to: quote.id, text: text) }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(commentText.isEmpty)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Quote")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if store == nil {
                store = QuoteStore(service: quoteService)
            }
            await store?.fetchComments(for: quote.id)
        }
    }

    private var currentQuote: Quote {
        store?.quotes.first(where: { $0.id == quote.id }) ?? quote
    }
}

#Preview {
    NavigationStack {
        QuoteDetailView(quote: Quote.samples[0])
    }
    .environment(\.quoteService, .mock)
}
