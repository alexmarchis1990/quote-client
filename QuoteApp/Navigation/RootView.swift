import SwiftUI

struct RootView: View {
    @Bindable var authStore: AuthStore

    var body: some View {
        if authStore.isAuthenticated {
            MainTabView(authStore: authStore)
        } else {
            unauthenticatedContent
        }
    }

    private var unauthenticatedContent: some View {
        NavigationStack {
            LoginView(authStore: authStore)
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .auth(.signup):
                        SignUpView(authStore: authStore)
                    default:
                        EmptyView()
                    }
                }
        }
    }
}

#Preview {
    RootView(authStore: AuthStore(service: .mock))
        .environment(\.authService, .mock)
}
