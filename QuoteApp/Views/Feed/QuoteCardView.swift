import SwiftUI

private let cardCornerRadius: CGFloat = 12
private let cardSpacing: CGFloat = 12
private let cardShadowRadius: CGFloat = 4
private let cardShadowY: CGFloat = 2

struct QuoteCardView: View {
    let quote: Quote
    let onLike: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: cardSpacing) {
            Text(quote.text)
                .font(.body)
                .italic()
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Text(quote.attribution)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            HStack(spacing: 20) {
                Button(action: onLike) {
                    HStack(spacing: 4) {
                        Image(systemName: quote.isLiked ? "heart.fill" : "heart")
                            .foregroundStyle(quote.isLiked ? .red : .secondary)
                        Text("\(quote.likes)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(quote.isLiked ? "Unlike, \(quote.likes) likes" : "Like, \(quote.likes) likes")

                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                        .foregroundStyle(.secondary)
                    Text("\(quote.commentCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("\(quote.commentCount) comments")

                Spacer()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .shadow(color: .black.opacity(0.05), radius: cardShadowRadius, y: cardShadowY)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(quote.attribution): \(quote.text)")
    }
}

#Preview {
    QuoteCardView(quote: Quote.samples[0], onLike: {})
        .padding()
}
