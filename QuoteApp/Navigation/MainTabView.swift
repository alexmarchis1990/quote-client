import SwiftUI

struct MainTabView: View {
    var authStore: AuthStore
    @State private var selectedTab = 0
    @State private var feedPath: [Screen] = []

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $feedPath) {
                FeedView()
                    .screenDestination()
            }
            .tabItem {
                Label("Feed", systemImage: "house.fill")
            }
            .tag(0)

            ScanQuoteView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(1)

            VStack(spacing: 20) {
                Text("Profile")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Button("Log Out", role: .destructive) {
                    Task {
                        await authStore.logout()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(2)
        }
    }
}

#Preview {
    MainTabView(authStore: AuthStore(service: .mock))
        .environment(\.quoteService, .mock)
}
