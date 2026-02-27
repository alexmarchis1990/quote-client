import SwiftUI

struct QuoteCardView: View {
    let quote: Quote
    let onLike: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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

                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                        .foregroundStyle(.secondary)
                    Text("\(quote.commentCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

#Preview {
    QuoteCardView(quote: Quote.samples[0], onLike: {})
        .padding()
}
