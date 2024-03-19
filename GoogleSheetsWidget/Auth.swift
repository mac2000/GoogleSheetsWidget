import SwiftUI
import CryptoKit
import SafariServices
import OSLog
import Shared

@Observable
class Auth {
    private let log = Logger("Auth")
    private var refreshToken: String?
    public var accessToken: String?
    public var isAuthenticated: Bool
    
    init() {
        if let refreshToken = RefreshTokenStorage.get() {
            log.info("authenticated")
            self.refreshToken = refreshToken
            self.isAuthenticated = true
        } else {
            log.info("anonymous")
            self.refreshToken = nil
            self.isAuthenticated = false
        }
    }
    
    func login() -> SafariWebView {
        return SafariWebView(url: GoogleAuth.auth()!)
    }
    
    func logout() {
        log.info("logout")
        RefreshTokenStorage.delete()
        self.refreshToken = nil
        self.isAuthenticated = false
    }
    
    func refresh() async -> String? {
        guard let refreshToken = self.refreshToken else { return nil }
        let response = await GoogleAuth.refresh(refreshToken)
        print("response", response ?? "nil")
        return response?.accessToken
    }
    
    func exchange(_ url: URL) {
        Task {
            let response = await GoogleAuth.exchange(url)
            self.log.info("authenticated, refresh_token=\(response?.refreshToken.prefix(6) ?? "N/A")")
            RefreshTokenStorage.set(response?.refreshToken)
            self.refreshToken = response?.refreshToken
            self.isAuthenticated = true
        }
    }
    
    func with(completion: @escaping (String?) -> Void) {
        Task {
            guard let accessToken = await refresh() else {
                log.warning("unable to refresh token")
                self.logout()
                return
            }
            completion(accessToken)
        }
    }
}

struct SafariWebView: UIViewControllerRepresentable {
    var url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
}

struct RefreshTokenStorage {
    static func get() -> String? {
        return Keychain.get("refresh_token")
    }
    
    static func set(_ value: String?) {
        Keychain.set("refresh_token", value)
    }
    
    static func delete() {
        Keychain.delete("refresh_token")
    }
}
