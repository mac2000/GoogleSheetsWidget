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
        let codeVerifier = UUID().uuidString
        var codeChallenge = ""
        // in preview mode everything brokes because of trimmingCharacters - cannot convert value of type 'OSLogMessage' to expected element type 'CharacterSet.ArrayLiteralElement' (aka 'Unicode.Scalar')
        do {
            codeChallenge = Data(SHA256.hash(data: Data(codeVerifier.utf8))).base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .trimmingCharacters(in: ["="])
        }
        
        var url = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        url.append(queryItems: [
            URLQueryItem(name:"response_type",value: "code"),
            URLQueryItem(name:"client_id",value: clientId),
            URLQueryItem(name:"redirect_uri",value: redirectUri),
            URLQueryItem(name:"scope",value: "https://www.googleapis.com/auth/drive.readonly"),
            URLQueryItem(name:"state",value: codeVerifier),
            URLQueryItem(name:"code_challenge",value: codeChallenge),
            URLQueryItem(name:"code_challenge_method",value: "S256")
        ])
        
        return SafariWebView(url: url)
    }
    
    func logout() {
        log.info("logout")
        RefreshTokenStorage.delete()
        self.refreshToken = nil
        self.isAuthenticated = false
    }
    
    func refresh() async throws -> String? {
        guard let refreshToken = self.refreshToken else {
            log.warning("can not refresh - refresh token is nil")
            return nil
        }
        var parameters = URLComponents()
        parameters.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "client_id", value: clientId)
        ]
        
        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters.query?.data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            log.warning("invalid json, calling logout")
            logout()
            return nil
        }
        
        if let accessToken = json["access_token"] as? String {
            log.warning("refreshed access_token=\(accessToken.prefix(4))")
            return accessToken
        } else {
            log.warning("refresh failed, calling logout")
            log.debug("\(json)")
            logout()
            return nil
        }
    }
    
    func exchange(_ url: URL) {
        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        guard let codeVerifier = url.queryItems?.first(where: { $0.name == "state" })?.value else { return }
        guard let code = url.queryItems?.first(where: { $0.name == "code" })?.value else { return }
        // guard let scope = url.queryItems?.first(where: { $0.name == "scope" })?.value else { return }
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "code_verifier", value: codeVerifier),
            URLQueryItem(name: "client_id", value: "165877850855-o5k0ftcnlh8cukro95ujd4vspbghfp58.apps.googleusercontent.com"),
            URLQueryItem(name: "redirect_uri", value: "com.googleusercontent.apps.165877850855-o5k0ftcnlh8cukro95ujd4vspbghfp58:/callback"),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    self.log.warning("invalid json, calling logout")
                    self.logout()
                    return
                }
                
                // self.log.debug("\(json)")

                guard let refreshToken = json["refresh_token"] as? String else {
                    self.log.warning("tokens missing, calling logout")
                    self.logout()
                    return
                }
                
                self.log.info("authenticated, refresh_token=\(refreshToken.prefix(6))")
                RefreshTokenStorage.set(refreshToken)
                self.refreshToken = refreshToken
                self.isAuthenticated = true
            }
        }.resume()
    }
    
    func with(completion: @escaping (String?) -> Void) {
        Task {
            guard let accessToken = try await refresh() else {
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
//    static let log = Logger("RefreshTokenStorage")
    
    static func get() -> String? {
        return Keychain.get("refresh_token")
//        var result: CFTypeRef?
//        let status = SecItemCopyMatching([
//            kSecClass: kSecClassGenericPassword,
//            kSecAttrService: service,
//            kSecAttrAccount: account,
//            kSecAttrAccessGroup: group,
//            kSecReturnData: kCFBooleanTrue as Any,
//            kSecMatchLimit: kSecMatchLimitOne
//        ] as CFDictionary, &result)
//        
//        guard status == errSecSuccess,
//              let data = result as? Data,
//              let token = String(data: data, encoding: .utf8) else {
//            let message = String(SecCopyErrorMessageString(status, nil) ?? "unknown" as CFString)
//            log.warning("token not retrieved because: \(message)")
//            return nil
//        }
//        
//        return token
    }
    
    static func set(_ value: String?) {
        //Keychain.set("refresh_token", value)
//        guard let value = value else {
//            log.warning("token will be deleted - nil value passed")
//            delete()
//            return
//        }
//        guard let data = value.data(using: .utf8) else {
//            log.warning("token not saved because: empty value given")
//            return
//        }
//        
//        let query = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: service,
//            kSecAttrAccount as String: account,
//            kSecAttrAccessGroup: group,
//            kSecValueData as String: data
//        ] as CFDictionary
//        
//        SecItemDelete(query as CFDictionary)
//        
//        let status = SecItemAdd(query, nil)
//        
//        if status == errSecSuccess {
//            log.info("token saved")
//        } else {
//            let message = String(SecCopyErrorMessageString(status, nil) ?? "unknown" as CFString)
//            log.warning("token not saved because: \(message)")
//        }
    }
    
    static func delete() {
        //Keychain.delete("refresh_token")
//        let status = SecItemDelete([
//            kSecClass: kSecClassGenericPassword,
//            kSecAttrService: service,
//            kSecAttrAccount: account,
//            kSecAttrAccessGroup: group
//        ] as CFDictionary)
//        
//        if status == errSecSuccess {
//            log.info("token deleted")
//        } else {
//            let message = String(SecCopyErrorMessageString(status, nil) ?? "unknown" as CFString)
//            log.warning("token not deleted because: \(message)")
//        }
    }
}
