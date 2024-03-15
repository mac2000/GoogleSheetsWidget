import SwiftUI

struct AuthenticatedView: View {
    var body: some View {
        TabView{
            Text("List")
            Text("Widgets")
            Text("Account")
        }.tabViewStyle(.page)
    }
}

#Preview {
    AuthenticatedView()
}
