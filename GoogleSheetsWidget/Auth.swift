import SwiftUI
import CryptoKit
import SafariServices
import OSLog
import Shared

@Observable
class Auth {
    private let log = Logger("Auth")
    private let clientId = "165877850855-o5k0ftcnlh8cukro95ujd4vspbghfp58.apps.googleusercontent.com"
    private let redirectUri = "com.googleusercontent.apps.165877850855-o5k0ftcnlh8cukro95ujd4vspbghfp58:/callback"
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
        
//        let codeVerifier = UUID().uuidString
//        var codeChallenge = ""
//        // in preview mode everything brokes because of trimmingCharacters - cannot convert value of type 'OSLogMessage' to expected element type 'CharacterSet.ArrayLiteralElement' (aka 'Unicode.Scalar')
//        do {
//            codeChallenge = Data(SHA256.hash(data: Data(codeVerifier.utf8))).base64EncodedString()
//                .replacingOccurrences(of: "+", with: "-")
//                .replacingOccurrences(of: "/", with: "_")
//                .trimmingCharacters(in: ["="])
//        }
//        
//        var url = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!
//        url.append(queryItems: [
//            URLQueryItem(name:"response_type",value: "code"),
//            URLQueryItem(name:"client_id",value: clientId),
//            URLQueryItem(name:"redirect_uri",value: redirectUri),
//            URLQueryItem(name:"scope",value: "https://www.googleapis.com/auth/drive.readonly"),
//            URLQueryItem(name:"state",value: codeVerifier),
//            URLQueryItem(name:"code_challenge",value: codeChallenge),
//            URLQueryItem(name:"code_challenge_method",value: "S256")
//        ])
//        
//        return SafariWebView(url: url)
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
        
//        guard let refreshToken = self.refreshToken else {
//            log.warning("can not refresh - refresh token is nil")
//            return nil
//        }
//        var parameters = URLComponents()
//        parameters.queryItems = [
//            URLQueryItem(name: "grant_type", value: "refresh_token"),
//            URLQueryItem(name: "refresh_token", value: refreshToken),
//            URLQueryItem(name: "client_id", value: clientId)
//        ]
//        
//        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
//        request.httpMethod = "POST"
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpBody = parameters.query?.data(using: .utf8)
//        
//        let (data, _) = try await URLSession.shared.data(for: request)
//        
//        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
//            log.warning("invalid json, calling logout")
//            logout()
//            return nil
//        }
//        
//        if let accessToken = json["access_token"] as? String {
//            log.warning("refreshed access_token=\(accessToken.prefix(4))")
//            return accessToken
//        } else {
//            log.warning("refresh failed, calling logout")
//            log.debug("\(json)")
//            logout()
//            return nil
//        }
    }
    
    func exchange(_ url: URL) {
        Task {
            let response = await GoogleAuth.exchange(url)
            self.log.info("authenticated, refresh_token=\(response?.refreshToken.prefix(6) ?? "N/A")")
            RefreshTokenStorage.set(response?.refreshToken)
            self.refreshToken = response?.refreshToken
            self.isAuthenticated = true
        }
//        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
//        guard let codeVerifier = url.queryItems?.first(where: { $0.name == "state" })?.value else { return }
//        guard let code = url.queryItems?.first(where: { $0.name == "code" })?.value else { return }
//        // guard let scope = url.queryItems?.first(where: { $0.name == "scope" })?.value else { return }
//        
//        var requestBodyComponents = URLComponents()
//        requestBodyComponents.queryItems = [
//            URLQueryItem(name: "code", value: code),
//            URLQueryItem(name: "code_verifier", value: codeVerifier),
//            URLQueryItem(name: "client_id", value: "165877850855-o5k0ftcnlh8cukro95ujd4vspbghfp58.apps.googleusercontent.com"),
//            URLQueryItem(name: "redirect_uri", value: "com.googleusercontent.apps.165877850855-o5k0ftcnlh8cukro95ujd4vspbghfp58:/callback"),
//            URLQueryItem(name: "grant_type", value: "authorization_code"),
//        ]
//        
//        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
//        request.httpMethod = "POST"
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
//                    self.log.warning("invalid json, calling logout")
//                    self.logout()
//                    return
//                }
//                
//                // self.log.debug("\(json)")
//
//                guard let refreshToken = json["refresh_token"] as? String else {
//                    self.log.warning("tokens missing, calling logout")
//                    self.logout()
//                    return
//                }
//                
//                self.log.info("authenticated, refresh_token=\(refreshToken.prefix(6))")
//                RefreshTokenStorage.set(refreshToken)
//                self.refreshToken = refreshToken
//                self.isAuthenticated = true
//            }
//        }.resume()
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
