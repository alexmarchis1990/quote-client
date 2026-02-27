import SwiftUI

private let profileSpacing: CGFloat = 20
private let feedTabTag = 0
private let addTabTag = 1
private let profileTabTag = 2
private let feedTabLabel = "Feed"
private let addTabLabel = "Add"
private let profileTabLabel = "Profile"
private let logOutButtonTitle = "Log Out"

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
                Label(feedTabLabel, systemImage: "house.fill")
            }
            .tag(feedTabTag)
            .accessibilityLabel(feedTabLabel)

            ScanQuoteView()
                .tabItem {
                    Label(addTabLabel, systemImage: "plus.circle.fill")
                }
                .tag(addTabTag)
                .accessibilityLabel(addTabLabel)

            profileTabContent
                .tabItem {
                    Label(profileTabLabel, systemImage: "person.fill")
                }
                .tag(profileTabTag)
                .accessibilityLabel(profileTabLabel)
        }
    }

    private var profileTabContent: some View {
        VStack(spacing: profileSpacing) {
            Text(profileTabLabel)
                .font(.title2)
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)

            Button(logOutButtonTitle, role: .destructive) {
                Task {
                    await authStore.logout()
                }
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel(logOutButtonTitle)
        }
    }
}

#Preview {
    MainTabView(authStore: AuthStore(service: .mock))
        .environment(\.quoteService, .mock)
}
