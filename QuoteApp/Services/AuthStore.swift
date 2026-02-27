import Foundation

@MainActor
@Observable
final class AuthStore {
    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }
    var loadingState: LoadingState = .idle

    private let service: AuthService

    init(service: AuthService) {
        self.service = service
    }

    func login(email: String, password: String) async {
        loadingState = .loading
        do {
            currentUser = try await service.login(email, password)
            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }

    func signup(email: String, password: String, username: String) async {
        loadingState = .loading
        do {
            currentUser = try await service.signup(email, password, username)
            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }

    func logout() async {
        do {
            try await service.logout()
        } catch {
            // Continue with local logout even if network call fails
        }
        currentUser = nil
        loadingState = .idle
    }

    func checkSession() async {
        guard TokenStore.token != nil else { return }
        loadingState = .loading
        do {
            currentUser = try await service.getCurrentUser()
            loadingState = .loaded
        } catch {
            TokenStore.clear()
            loadingState = .idle
        }
    }
}
