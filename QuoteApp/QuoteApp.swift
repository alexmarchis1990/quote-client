import SwiftUI

@main
struct QuoteApp: App {
    @State private var authStore = AuthStore(service: .live())

    var body: some Scene {
        WindowGroup {
            RootView(authStore: authStore)
                .environment(\.quoteService, .mock)
                .environment(\.authService, .mock)
        }
    }
}
