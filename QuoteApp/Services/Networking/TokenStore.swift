import Foundation

enum TokenStore {
    private static let key = "auth_token"

    @MainActor
    static var token: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    @MainActor
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
