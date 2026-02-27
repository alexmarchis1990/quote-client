import Foundation
import SwiftUI

struct AuthService: Sendable {
    var login: @Sendable (_ email: String, _ password: String) async throws -> User
    var signup: @Sendable (_ email: String, _ password: String, _ username: String) async throws -> User
    var logout: @Sendable () async throws -> Void
    var getCurrentUser: @Sendable () async throws -> User
}

// MARK: - Live

extension AuthService {
    static func live(client: APIClient = APIClient()) -> AuthService {
        AuthService(
            login: { email, password in
                let body = ["email": email, "password": password]
                let response: AuthResponseApiModel = try await client.post("/auth/login", body: body)
                guard let token = response.token, let user = response.user?.domainModel else {
                    throw APIError.decodingError
                }
                TokenStore.token = token
                return user
            },
            signup: { email, password, username in
                let body = ["email": email, "password": password, "username": username]
                let response: AuthResponseApiModel = try await client.post("/auth/signup", body: body)
                guard let token = response.token, let user = response.user?.domainModel else {
                    throw APIError.decodingError
                }
                TokenStore.token = token
                return user
            },
            logout: {
                try await client.postEmpty("/auth/logout")
                TokenStore.clear()
            },
            getCurrentUser: {
                let apiModel: UserApiModel = try await client.get("/auth/me")
                guard let user = apiModel.domainModel else { throw APIError.decodingError }
                return user
            }
        )
    }
}

// MARK: - Mock

extension AuthService {
    static let mock = AuthService(
        login: { email, _ in
            try? await Task.sleep(for: .milliseconds(500))
            return User(id: "mock-1", email: email, username: "mockuser")
        },
        signup: { email, _, username in
            try? await Task.sleep(for: .milliseconds(500))
            return User(id: "mock-1", email: email, username: username)
        },
        logout: {
            try? await Task.sleep(for: .milliseconds(200))
            TokenStore.clear()
        },
        getCurrentUser: {
            try? await Task.sleep(for: .milliseconds(300))
            return User(id: "mock-1", email: "mock@example.com", username: "mockuser")
        }
    )
}

// MARK: - Preview

extension AuthService {
    static let preview = mock
}

// MARK: - Unimplemented

extension AuthService {
    static let unimplemented = AuthService(
        login: { _, _ in fatalError("login not implemented") },
        signup: { _, _, _ in fatalError("signup not implemented") },
        logout: { fatalError("logout not implemented") },
        getCurrentUser: { fatalError("getCurrentUser not implemented") }
    )
}

// MARK: - Environment

extension EnvironmentValues {
    @Entry var authService: AuthService = .unimplemented
}
