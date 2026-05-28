import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let tokenKey = "OAuth2Token"

    private init() { }

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            guard let token = newValue else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
                return
            }
            let isSuccess = KeychainWrapper.standard.set(token, forKey: tokenKey)
            guard isSuccess else {
                print("[OAuth2TokenStorage] Ошибка: не удалось сохранить токен в Keychain")
                return
            }
        }
    }
}
