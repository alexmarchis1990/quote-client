import SwiftUI

private let commentAvatarSize: CGFloat = 32
private let commentSpacing: CGFloat = 10

struct CommentView: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: commentSpacing) {
            commentAvatar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.username)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(comment.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(comment.text)
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(comment.username), \(comment.formattedDate): \(comment.text)")
    }

    private var commentAvatar: some View {
        Circle()
            .fill(.secondary.opacity(0.3))
            .frame(width: commentAvatarSize, height: commentAvatarSize)
            .overlay {
                Text(String(comment.username.prefix(1)).uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    CommentView(comment: Comment.samples[0])
        .padding()
}
