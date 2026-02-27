import Foundation

enum Screen: Hashable {
    case quote(QuoteScreen)
    case auth(AuthScreen)

    enum QuoteScreen: Hashable {
        case feed
        case detail(Quote)
    }

    enum AuthScreen: Hashable {
        case login
        case signup
    }
}
