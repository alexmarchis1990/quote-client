import Foundation

enum TokenStore {
    private static let key = "auth_token"

    static var token: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
