import Foundation
import CryptoKit
import OSLog

public final actor GoogleAuth {
    private static let log = Logger("GoogleAuth")
    private static let clientId = "165877850855-o5k0ftcnlh8cukro95ujd4vspbghfp58.apps.googleusercontent.com"
    private static let redirectUri = "com.googleusercontent.apps.165877850855-o5k0ftcnlh8cukro95ujd4vspbghfp58:/callback"
    private static let scope = "https://www.googleapis.com/auth/drive.readonly"

    // Used for authentication, just open an generated link, and after user authentication, your app `onOpenUrl` will be called which should be handled by `exchange` method
    public static func auth() -> URL? {
        let codeVerifier = UUID().uuidString
        var codeChallenge = ""
        // in preview mode everything brokes because of trimmingCharacters - cannot convert value of type 'OSLogMessage' to expected element type 'CharacterSet.ArrayLiteralElement' (aka 'Unicode.Scalar')
        do {
            codeChallenge = Data(SHA256.hash(data: Data(codeVerifier.utf8))).base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .trimmingCharacters(in: ["="])
        }

        return URL("https://accounts.google.com/o/oauth2/v2/auth", [
            "response_type": "code",
            "client_id": clientId,
            "redirect_uri": redirectUri,
            "scope": scope,
            "state": codeVerifier,// FIXME: this one should be stored in memory
            "code_challenge": codeChallenge,
            "code_challenge_method": "S256"
        ])
    }

    public static func exchange(_ url: URL) async -> RefreshableAuthTokens? {
        print("open", url)
        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        guard let codeVerifier = url.queryItems?.first(where: { $0.name == "state" })?.value else { return nil }
        guard let code = url.queryItems?.first(where: { $0.name == "code" })?.value else { return nil }
        guard let request = URLRequest("https://oauth2.googleapis.com/token", [
            "code": code,
            "code_verifier": codeVerifier,
            "client_id": clientId,
            "redirect_uri": redirectUri,
            "grant_type": "authorization_code"
        ]) else { return nil }

        return try? await URLSession.shared.decoded(request)
    }

    public static func refresh(_ refreshToken: String) async -> AuthTokens? {
        guard let request = URLRequest("https://oauth2.googleapis.com/token", [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": clientId
        ]) else { return nil }

        return try? await URLSession.shared.decoded(request)
    }
}

public struct AuthTokens: Decodable, Sendable {
    public let accessToken: String
    public let scope: String
    public let tokenType: String
    public let expiresIn: Int
}

public struct RefreshableAuthTokens: Decodable, Sendable {
    public let accessToken: String
    public let scope: String
    public let tokenType: String
    public let expiresIn: Int
    public let refreshToken: String
}
