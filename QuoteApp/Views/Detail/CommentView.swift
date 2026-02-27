import SwiftUI

struct CommentView: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(.secondary.opacity(0.3))
                .frame(width: 32, height: 32)
                .overlay {
                    Text(String(comment.username.prefix(1)).uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }

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
    }
}

#Preview {
    CommentView(comment: Comment.samples[0])
        .padding()
}
