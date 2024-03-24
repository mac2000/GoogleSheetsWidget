import SwiftUI
import CryptoKit
import SafariServices
import Shared

struct AnonymousView: View {
    @Environment(Auth.self) var auth
    @State private var isVisible = false
    var body: some View {
        VStack(spacing:20) {
            Image(systemName: "lock").imageScale(.large).foregroundStyle(.tint)
            Text("Anonymous")
            // Link("Login", destination: url)
            Button("Login") { isVisible.toggle() }.popover(isPresented: $isVisible, content: auth.login)
        }
    }
    
}

#Preview {
    AnonymousView()
        .environment(Auth.shared)
}
