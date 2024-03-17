import SwiftUI

struct CustomForm: View {
    @State private var number = 1
    @State private var numbers = [1,2,3]
    @State private var item: CustomPickerItem?
    
    var body: some View {
        Form {
            Section("Default") {
                Picker("Number", selection: $number) {
                    ForEach(numbers, id: \.self) { number in
                        Text("\(number)")
                    }
                }
                .pickerStyle(.navigationLink)
            }
            
            Section("Custom") {
                NavigationLink {
                    CustomPicker(item: $item)
                    .onSubmit {
                        print("Submitted?")
                    }
                } label: {
                    HStack {
                        Text("Custom")
                        Spacer()
                        Text(item?.name ?? "N/A").foregroundStyle(.secondary)
                    }
                }.isDetailLink(false)
            }
            
            
        }
        .navigationTitle("Pickers")
    }
}

#Preview {
    NavigationStack {
        CustomForm()
    }
}
