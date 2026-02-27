import SwiftUI

struct LoadingStateView<Content: View>: View {
    let state: LoadingState
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch state {
        case .idle:
            Color.clear
                .accessibilityHidden(true)
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Loading")
        case .loaded:
            content()
        case .error(let message):
            ContentUnavailableView {
                Label("Error", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Error: \(message)")
        }
    }
}
