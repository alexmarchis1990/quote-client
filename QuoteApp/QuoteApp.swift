import SwiftUI

@main
struct QuoteApp: App {
    @State private var authStore = AuthStore(service: .live())
    @State private var quoteStore = QuoteStore(service: .mock)

    var body: some Scene {
        WindowGroup {
            RootView(authStore: authStore)
                .environment(quoteStore)
                .environment(\.quoteService, .mock)
                .environment(\.authService, .mock)
                .task { await authStore.checkSession() }
        }
    }
}
