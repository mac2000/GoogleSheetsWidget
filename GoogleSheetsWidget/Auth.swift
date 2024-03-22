import SwiftUI
import CryptoKit
import SafariServices
import OSLog
import Shared

@Observable
class Auth {
    private let log = Logger("Auth")
    
    private var refreshToken: String?
    public var isAuthenticated: Bool {
        return refreshToken != nil && refreshToken != ""
    }
    
    public var accessToken: String?
    private var expirationTime: Date?
    private var isAccessTokenEmpty: Bool {
        return accessToken == nil || accessToken == ""
    }
    private var isAccessTokenExpired: Bool {
        guard let expirationTime = expirationTime else {
            return true
        }
        return Date() >= expirationTime
    }
    private var isAccessTokenInvalid: Bool {
        return isAccessTokenEmpty || isAccessTokenExpired
    }

    init() {
        if let refreshToken = RefreshTokenStorage.get() {
            log.info("authenticated")
            self.refreshToken = refreshToken
        } else {
            log.info("anonymous")
            self.refreshToken = nil
        }
    }
    
    func login() -> SafariWebView {
        return SafariWebView(url: GoogleAuth.auth()!)
    }
    
    func logout() {
        log.info("logout")
        RefreshTokenStorage.delete()
        self.refreshToken = nil
        self.accessToken = nil
        self.expirationTime = nil
    }
    
    func refresh() async -> String? {
        if !isAccessTokenInvalid {
            log.info("reusing access token")
            return accessToken
        }

        guard let refreshToken = self.refreshToken else { return nil }
        guard let response = await GoogleAuth.refresh(refreshToken) else { return nil }
        print("response", response)
        
        self.accessToken = response.accessToken
        self.expirationTime = getSafeExpirationTime(response.expiresIn)
        
        return self.accessToken
    }
    
    func exchange(_ url: URL) {
        Task {
            guard let response = await GoogleAuth.exchange(url) else {
                log.warning("got nil response while exchanging code for tokens")
                return
            }
            log.info("exchanged")
            RefreshTokenStorage.set(response.refreshToken)
            
            self.refreshToken = response.refreshToken
            self.accessToken = response.accessToken
            self.expirationTime = getSafeExpirationTime(response.expiresIn)
        }
    }
    
    private func getSafeExpirationTime(_ expiresIn: Int) -> Date? {
        let safeExpiresIn = Int(round(Double(expiresIn) * 0.8))
        return Calendar.current.date(byAdding: .second, value: safeExpiresIn, to: Date())
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
    static let key = "refresh_token"

    static func get() -> String? {
        return Keychain.get(key)
    }
    
    static func set(_ value: String?) {
        Keychain.set(key, value)
    }
    
    static func delete() {
        Keychain.delete(key)
    }
}
