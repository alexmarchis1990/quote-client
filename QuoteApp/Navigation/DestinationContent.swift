import SwiftUI

struct ScreenDestinationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Screen.self) { screen in
                destinationContent(for: screen)
            }
    }

    @ViewBuilder
    private func destinationContent(for screen: Screen) -> some View {
        switch screen {
        case .quote(let quoteScreen):
            switch quoteScreen {
            case .feed:
                FeedView()
            case .detail(let quote):
                QuoteDetailView(quote: quote)
            }
        case .auth:
            EmptyView()
        }
    }
}

extension View {
    func screenDestination() -> some View {
        modifier(ScreenDestinationModifier())
    }
}
