import SwiftUI

struct GridLikeView: View {
    @State private var data: [[String]] = [
        ["works", "bank", "vendor", "card", "card_currency", "bank_fee", "service", "service_currency", "method", "service_fee", "date"],
        ["TRUE", "А-Банк", "MasterCard", "Debit", "USD", "3,00%", "Wise", "EUR", "P2P", "0,00%", "22.02.2024"],
        ["TRUE", "А-Банк", "MasterCard", "Debit", "EUR", "1,00%", "Wise", "EUR", "Google Pay", "0,41%", "22.02.2024"],
        ["TRUE", "Банк Глобус", "MasterCard", "Debit", "EUR", "0,00%", "Wise", "EUR", "Google Pay", "0,47%", "12.02.2024"],
        ["TRUE", "Банк Глобус", "MasterCard", "Debit", "EUR", "0,00%", "Revolut", "EUR", "Google Pay", "2,50%", "24.02.2024"],
        ["TRUE", "Банк Глобус", "MasterCard", "Debit", "USD", "0,00%", "Revolut", "USD", "Google Pay", "2,50%", "24.02.2024"],
        ["TRUE", "Банк Південний", "Visa", "Debit", "USD", "0,00%", "Wise", "USD", "Google Pay", "1,56%", "21.02.2024"],
        ["TRUE", "Банк Південний", "MasterCard", "Debit", "EUR", "0,00%", "Wise", "EUR", "Google Pay", "0,47%", "21.02.2024"],
        ["TRUE", "Ізібанк", "MasterCard", "Debit", "USD", "0,00%", "Revolut", "USD", "Google Pay", "2,50%", "24.02.2024"],
        ["TRUE", "Ізібанк", "MasterCard", "Debit", "EUR", "0,00%", "Revolut", "EUR", "Google Pay", "2,50%", "24.02.2024"],
        ["FALSE", "Ізібанк", "MasterCard", "Debit", "EUR", "100%", "Wise", "EUR", "Google Pay", "100%", "22.02.2024"],
        ["TRUE", "Кліринговий Дім", "Visa", "Debit", "EUR", "1%", "Wise", "EUR", "Google Pay", "0,41%", "20.03.2024"],
        ["TRUE", "Кліринговий Дім", "Visa", "Debit", "USD", "0,00%", "Revolut", "USD", "Google Pay", "0,00%", "22.02.2024"],
        ["TRUE", "Креді Агріколь", "MasterCard", "Credit", "USD", "3,00%", "Wise", "USD", "Google Pay", "4,00%", "28.02.2024"],
        ["TRUE", "Креді Агріколь", "MasterCard", "Credit", "EUR", "3,00%", "Wise", "EUR", "Google Pay", "4,00%", "28.02.2024"],
        ["TRUE", "Креді Агріколь", "MasterCard", "Credit", "USD", "4,00%", "Wise", "EUR", "Google Pay", "0,62%", "28.02.2024"],
        ["TRUE", "Кредобанк", "MasterCard", "Debit", "USD", "0,00%", "Revolut", "USD", "Google Pay", "0,00%", "12.02.2024"],
        ["TRUE", "Кредобанк", "MasterCard", "Debit", "EUR", "0,00%", "Wise", "EUR", "Google Pay", "0,41%", "01.01.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "USD", "1,00%", "Wise", "USD", "P2P", "0,00%", "24.02.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "USD", "0,00%", "Revolut", "USD", "Google Pay", "0,00%", "01.03.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "EUR", "1,00%", "Revolut", "EUR", "P2P", "0,00%", "02.02.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "USD", "0,00%", "Wise", "GBP", "Google Pay", "0,42%", "22.02.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "EUR", "0,00%", "Wise", "GBP", "Google Pay", "0,42%", "22.02.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "USD", "0,00%", "Wise", "EUR", "Google Pay", "0,41%", "22.02.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "EUR", "0,00%", "Wise", "EUR", "Google Pay", "0,47%", "20.03.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "EUR", "1,00%", "Wise", "EUR", "P2P", "0,00%", "18.02.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "USD", "1,00%", "Revolut", "EUR", "P2P", "0,00%", "19.10.2023"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "USD", "0,00%", "Revolut", "USD", "P2P", "0,00%", "13.03.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "EUR", "0,00%", "Revolut", "EUR", "P2P", "0,00%", "13.03.2024"],
        ["TRUE", "Ощадбанк", "MasterCard", "Debit", "USD", "0,00%", "Wise", "USD", "Google Pay", "1,56%", "15.02.2024"],
        ["TRUE", "Ощадбанк", "MasterCard", "Debit", "USD", "0,00%", "Revolut", "USD", "Google Pay", "0,00%", "12.03.2024"],
        ["TRUE", "Приватбанк", "Visa", "Debit", "USD", "1,00%", "Wise", "USD", "P2P", "0,00%", "13.03.2024"],
        ["TRUE", "Приватбанк", "Visa", "Debit", "EUR", "1,00%", "Wise", "EUR", "P2P", "4,50%", "02.03.2024"],
        ["TRUE", "Приватбанк", "MasterCard", "Debit", "USD", "2,00%", "Wise", "EUR", "Google Pay", "0,41%", "06.03.2024"],
        ["TRUE", "Приватбанк", "MasterCard", "Debit", "EUR", "2,00%", "Wise", "EUR", "Google Pay", "0,41%", "06.03.2024"],
        ["TRUE", "Приватбанк", "MasterCard", "Debit", "USD", "2,00%", "Wise", "USD", "Google Pay", "1,54%", "06.03.2024"],
        ["TRUE", "Прокредитбанк", "Visa", "Debit", "USD", "0,00%", "Revolut", "USD", "Google Pay", "0,00%", "22.02.2024"],
        ["TRUE", "ПУМБ", "MasterCard", "Debit", "USD", "0,00%", "Revolut", "USD", "Google Pay", "0,00%", "12.02.2024"],
        ["TRUE", "ПУМБ", "MasterCard", "Debit", "USD", "0,00%", "Revolut", "EUR", "Google Pay", "0,41%", "12.02.2024"],
        ["TRUE", "ПУМБ", "MasterCard", "Debit", "USD", "0,00%", "Wise", "EUR", "Google Pay", "0,41%", "07.03.2024"],
        ["TRUE", "ПУМБ", "MasterCard", "Debit", "EUR", "0,00%", "Wise", "EUR", "Google Pay", "0,41%", "01.01.2024"],
        ["TRUE", "ПУМБ", "MasterCard", "Debit", "USD", "0,00%", "Wise", "USD", "Google Pay", "1,56%", "01.01.2024"],
        ["TRUE", "Райффайзен Банк", "Visa", "Debit", "USD", "0,00%", "Revolut", "USD", "Google Pay", "0,00%", "12.02.2024"],
        ["TRUE", "Райффайзен Банк", "Visa", "Debit", "USD", "0,00%", "Wise", "USD", "Google Pay", "1,56%", "13.03.2024"],
        ["TRUE", "Сенс Банк", "MasterCard", "Debit", "USD", "0,00%", "Revolut", "USD", "Google Pay", "0,00%", "24.02.2024"],
        ["TRUE", "Сенс Банк", "Visa", "Debit", "USD", "4,00%", "Revolut", "USD", "Google Pay", "2,50%", "24.02.2024"],
        ["TRUE", "Таскомбанк", "Visa", "Debit", "USD", "0,00%", "Revolut", "USD", "Google Pay", "0,00%", "12.02.2024"],
        ["FALSE", "Таскомбанк", "MasterCard", "Debit", "EUR", "100%", "Wise", "EUR", "Google Pay", "100%", "22.02.2024"],
        ["TRUE", "Укргазбанк", "MasterCard", "Debit", "USD", "0,00%", "Wise", "EUR", "Google Pay", "0,47%", "29.02.2024"],
        ["TRUE", "Укргазбанк", "Visa", "Debit", "EUR", "0,00%", "Wise", "EUR", "Google Pay", "0,47%", "29.02.2024"],
        ["TRUE", "Укргазбанк", "MasterCard", "Debit", "USD", "0,00%", "Revolut", "USD", "Google Pay", "0,00%", "22.02.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "EUR", "0,00%", "ZEN", "EUR", "Apple Pay", "3,00%", "20.03.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "EUR", "0,00%", "ZEN", "EUR", "Google Pay", "3,00%", "20.03.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "USD", "0,00%", "ZEN", "USD", "Apple Pay", "3,00%", "20.03.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "USD", "0,00%", "ZEN", "USD", "Google Pay", "3,00%", "20.03.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "EUR", "1,00%", "ZEN", "EUR", "P2P", "3,00%", "20.03.2024"],
        ["TRUE", "Монобанк", "MasterCard", "Debit", "USD", "1,00%", "ZEN", "USD", "P2P", "3,00%", "20.03.2024"]
    ]
    
    private var columns: [GridItem] {
        return data[0].map { _ in
            GridItem(.fixed(100))
        }
    }
    
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
            
        } .padding()
    }
}

#Preview {
    GridLikeView()
}
