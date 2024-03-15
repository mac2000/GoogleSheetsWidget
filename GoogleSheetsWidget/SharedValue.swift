import SwiftUI
import WidgetKit

struct SharedValue: View {
    @AppStorage("value", store: UserDefaults.init(suiteName: "group.GoogleSheetsWidget")) private var value: String = "X"
    
    var body: some View {
        Form {
            TextField("Value", text: $value)
                .onChange(of: value) { oldValue, newValue in
                    if oldValue != newValue {
                        print("changed")
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
        }
        .onSubmit {
            print("submitted")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

#Preview {
    SharedValue()
}
