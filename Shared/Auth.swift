import SwiftUI
import CryptoKit
import SafariServices
import OSLog

@Observable @MainActor public final class Auth {
    public static let shared = Auth()
    private init() {
        if let refreshToken = RefreshTokenStorage.get() {
            log.info("authenticated")
            self.refreshToken = refreshToken
        } else {
            log.info("anonymous")
            self.refreshToken = nil
        }
    }
    
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
    
    public func login() -> SafariWebView {
        return SafariWebView(url: GoogleAuth.auth()!)
    }
    
    public func logout() {
        log.info("logout")
        RefreshTokenStorage.delete()
        self.refreshToken = nil
        self.accessToken = nil
        self.expirationTime = nil
    }
    
    public func refresh() async -> String? {
        if !isAccessTokenInvalid {
            log.info("reusing access token")
            return accessToken
        }

        guard let refreshToken = self.refreshToken else { return nil }
        guard let response = await GoogleAuth.refresh(refreshToken) else {
            log.info("unable to refresh token, logging out")
            logout()
            return nil
        }
        print("response", response)
        
        self.accessToken = response.accessToken
        self.expirationTime = getSafeExpirationTime(response.expiresIn)
        
        return self.accessToken
    }
    
    public func exchange(_ url: URL) async {
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
    
    private func getSafeExpirationTime(_ expiresIn: Int) -> Date? {
        let safeExpiresIn = Int(round(Double(expiresIn) * 0.8))
        return Calendar.current.date(byAdding: .second, value: safeExpiresIn, to: Date())
    }
}

public struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    public func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
}

final actor RefreshTokenStorage {
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
