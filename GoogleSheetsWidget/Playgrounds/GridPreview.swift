import SwiftUI
import Shared

struct GridPreview: View {
    // https://developers.google.com/oauthplayground
    // step1: https://www.googleapis.com/auth/drive.readonly
    let accessToken = "ya29.a0Ad52N38zkKGBJ022CzTsHwtavToFgdpyZJbze0D22o-ROZnae5JEUD7mUdoEVxbEYETQwxH4ZvvmNNPEoVdarYKfFXK-c--TRqijzn8UES3hUbFQ2mrZdl1BN4SEawKid5PNjdFzJKHX4OoHNmhN21B3NjLQmEgoIL6KaCgYKAaQSARASFQHGX2Mic6o2vE8zfbmh5t-bUAXD9w0171"
    
//    let spreadsheetId = "1h2hXH-lt7EuB4Ic1z8LBz2P5U2I6R9GdizlpyXQ7fKY"
//    let sheetName = "'ОВДП в гривні'"
//    let range = "B1:I20"
    
//    let spreadsheetId = "1h2hXH-lt7EuB4Ic1z8LBz2P5U2I6R9GdizlpyXQ7fKY"
//    let sheetName = "'Валютні військові облігації'"
//    let range = "B2:L10"
    
    let spreadsheetId = "1d78yVZ569Glf0Zxsu29eDED00veHjd8Gk4GxyIxkx1I"
    let sheetName = "Data"
    let range = "A1:O"
    
    @State private var data: [[String]] = [[]]
    
    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            Grid(alignment:.leading,horizontalSpacing: 0,verticalSpacing: 0) {
                ForEach(data, id: \.self) { row in
                    GridRow(alignment:.top) {
                        ForEach(row, id: \.self) { cell in
                            Button(action: {
                                print(cell)
                            }, label: {
                                Text(cell)
                                    .frame(width: 100, height: 21, alignment: .leading)
                                    .padding(5)
                                    .border(Color.black, width: 1)
                                    .padding(.trailing, -1)
                                    .padding(.bottom, -1)
                                    .foregroundColor(.primary)
                            })
                        }
                    }
                }
            }
            
        }
        .task {
            let data = await GoogleSheets.getValues(accessToken, spreadsheetId, sheetName, range)
            let maxColumns = data.map({ $0.count }).max() ?? 0
            self.data = data.map { row in
                return row + Array(repeating: "", count: maxColumns - row.count)
            }.filter { row in
                let uniqueValues = Set(row)
                return uniqueValues != ["", "TRUE", "FALSE"] && uniqueValues != ["", "TRUE"] && uniqueValues != ["", "FALSE"]
            }
        }
    }
}

#Preview {
    GridPreview()
}
