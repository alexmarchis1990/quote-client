import Foundation
import Testing

@testable import QuoteApp

@MainActor
@Suite("AuthStore")
struct AuthStoreTests {

  private let mockUser = User(id: "u1", email: "test@example.com", username: "tester")

  // MARK: - Initial state

  @Test("isAuthenticated is false before any login")
  func initialState() {
    let store = AuthStore(service: makeAuthService())

    #expect(!store.isAuthenticated)
    #expect(store.currentUser == nil)
    #expect(store.loadingState == .idle)
  }

  // MARK: - login

  @Test("login success sets currentUser and .loaded state")
  func loginSuccess() async {
    let user = mockUser
    let store = AuthStore(service: makeAuthService(login: { _, _ in user }))

    await store.login(email: user.email, password: "secret")

    #expect(store.currentUser == user)
    #expect(store.loadingState == .loaded)
    #expect(store.isAuthenticated)
  }

  @Test("login failure leaves currentUser nil and sets .error state")
  func loginFailure() async {
    let store = AuthStore(service: makeAuthService(
      login: { _, _ in throw APIError.invalidResponse }
    ))

    await store.login(email: "bad@example.com", password: "wrong")

    #expect(store.currentUser == nil)
    #expect(!store.isAuthenticated)
    guard case .error = store.loadingState else {
      Issue.record("Expected .error loading state, got \(store.loadingState)")
      return
    }
  }

  // MARK: - signup

  @Test("signup success sets currentUser and .loaded state")
  func signupSuccess() async {
    let user = mockUser
    let store = AuthStore(service: makeAuthService(signup: { _, _, _ in user }))

    await store.signup(email: user.email, password: "pass123", username: user.username)

    #expect(store.currentUser == user)
    #expect(store.loadingState == .loaded)
  }

  @Test("signup failure leaves currentUser nil and sets .error state")
  func signupFailure() async {
    let store = AuthStore(service: makeAuthService(
      signup: { _, _, _ in throw APIError.invalidResponse }
    ))

    await store.signup(email: "new@example.com", password: "pass123", username: "newuser")

    #expect(store.currentUser == nil)
    guard case .error = store.loadingState else {
      Issue.record("Expected .error loading state, got \(store.loadingState)")
      return
    }
  }

  // MARK: - logout

  @Test("logout clears currentUser and resets to .idle state")
  func logoutClearsUser() async {
    let user = mockUser
    let store = AuthStore(service: makeAuthService(
      login: { _, _ in user },
      logout: {}
    ))
    await store.login(email: user.email, password: "secret")
    #expect(store.isAuthenticated)

    await store.logout()

    #expect(store.currentUser == nil)
    #expect(!store.isAuthenticated)
    #expect(store.loadingState == .idle)
  }

  @Test("logout clears user even when the network call throws")
  func logoutIgnoresNetworkError() async {
    let user = mockUser
    let store = AuthStore(service: makeAuthService(
      login: { _, _ in user },
      logout: { throw APIError.networkError(URLError(.notConnectedToInternet)) }
    ))
    await store.login(email: user.email, password: "secret")

    await store.logout()

    #expect(store.currentUser == nil)
    #expect(!store.isAuthenticated)
  }
}
