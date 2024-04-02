import SwiftUI
import CryptoKit
import SafariServices
import Shared

struct AnonymousView: View {
    @Environment(Auth.self) var auth
    @State private var isVisible = false
    var body: some View {
        VStack(spacing:20) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width:200)
            Text("Sign in to start tracking")
            Button("Login") { isVisible.toggle() }.popover(isPresented: $isVisible, content: auth.login)
                .buttonStyle(.borderedProminent)
            Text("You will be promted by Google login.").foregroundStyle(.secondary)
        }
    }
    
}

#Preview {
    AnonymousView()
        .environment(Auth.shared)
}
