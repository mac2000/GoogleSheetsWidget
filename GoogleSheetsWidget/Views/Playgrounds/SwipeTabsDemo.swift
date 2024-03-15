import SwiftUI

struct HomePage: View {
    var body: some View {
        Text("Home Page")
    }
}

// https://medium.com/@jakir/swiftui-tabview-e487df6bd065
struct SwipeTabsDemo: View {
    var body: some View {
        TabView{
            HomePage()
            Text("Account Page")
            Text("Setting Page")
        }.tabViewStyle(.page)
    }
}

#Preview {
    SwipeTabsDemo()
}
