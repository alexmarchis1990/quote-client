import SwiftUI

private let detailSectionSpacing: CGFloat = 20
private let detailBlockSpacing: CGFloat = 12
private let detailCardCornerRadius: CGFloat = 12
private let detailNavigationTitle = "Quote"
private let commentPlaceholder = "Add a comment..."
private let noCommentsMessage = "No comments yet. Be the first!"
private let commentsSectionTitle = "Comments"

struct QuoteDetailView: View {
    let quote: Quote
    @Environment(\.quoteService) private var quoteService
    @State private var store: QuoteStore?
    @State private var commentText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: detailSectionSpacing) {
                quoteHeader
                commentsSection
                addCommentRow
            }
            .padding(.vertical)
        }
        .navigationTitle(detailNavigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if store == nil {
                store = QuoteStore(service: quoteService)
            }
            await store?.fetchComments(for: quote.id)
        }
        .accessibilityLabel("Quote detail: \(quote.attribution)")
    }

    private var currentQuote: Quote {
        store?.quotes.first(where: { $0.id == quote.id }) ?? quote
    }

    private var quoteHeader: some View {
        VStack(alignment: .leading, spacing: detailBlockSpacing) {
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
                .accessibilityLabel(currentQuote.isLiked
                    ? "Unlike"
                    : "Like")

                Spacer()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: detailCardCornerRadius))
    }

    @ViewBuilder
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: detailBlockSpacing) {
            Text(commentsSectionTitle)
                .font(.headline)

            if let store {
                LoadingStateView(state: store.commentLoadingState) {
                    if store.comments.isEmpty {
                        Text(noCommentsMessage)
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
    }

    private var addCommentRow: some View {
        HStack {
            TextField(commentPlaceholder, text: $commentText)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel("Comment text")

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
            .accessibilityLabel("Post comment")
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        QuoteDetailView(quote: Quote.samples[0])
    }
    .environment(\.quoteService, .mock)
}
