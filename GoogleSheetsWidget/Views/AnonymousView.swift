import SwiftUI
import CryptoKit
import SafariServices

struct AnonymousView: View {
    @State private var isVisible = false
    var body: some View {
        VStack(spacing:20) {
            Image(systemName: "lock").imageScale(.large).foregroundStyle(.tint)
            Text("Anonymous")
            // Link("Login", destination: url)
            Button("Login") { isVisible.toggle() }.popover(isPresented: $isVisible, content: {
                SafariWebView()
            })
        }
    }
    
}

fileprivate struct SafariWebView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let url = buildUrl()
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
    
    func buildUrl() -> URL {
        let codeVerifier = UUID().uuidString
        var codeChallenge = ""
        do { // in preview mode everything brokes because of trimmingCharacters - cannot convert value of type 'OSLogMessage' to expected element type 'CharacterSet.ArrayLiteralElement' (aka 'Unicode.Scalar')
            codeChallenge = Data(SHA256.hash(data: Data(codeVerifier.utf8))).base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .trimmingCharacters(in: ["="])
        }
        
        var url = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        url.append(queryItems: [
            URLQueryItem(name:"response_type",value: "code"),
            URLQueryItem(name:"client_id",value: "165877850855-o5k0ftcnlh8cukro95ujd4vspbghfp58.apps.googleusercontent.com"),
            URLQueryItem(name:"redirect_uri",value: "com.googleusercontent.apps.165877850855-o5k0ftcnlh8cukro95ujd4vspbghfp58:/callback"),
            URLQueryItem(name:"scope",value: "https://www.googleapis.com/auth/drive.readonly"),
            URLQueryItem(name:"state",value: codeVerifier),
            URLQueryItem(name:"code_challenge",value: codeChallenge),
            URLQueryItem(name:"code_challenge_method",value: "S256")
        ])
        
        return url
    }
}

#Preview {
    AnonymousView()
}
