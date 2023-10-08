//
//  ContentView.swift
//  wallet
//
//  Created by Валерий Никитин on 08.10.2023.
//

import SwiftUI


struct Account {
    var id: UUID = UUID()
    var balance: Double
}

struct Transaction {
    var id: UUID = UUID()
    var amount: Double
    var recipient: String
    var date: Date
}


struct ContentView: View {
    @State private var accounts = [Account(balance: 1000)]
    @State private var transactions: [Transaction] = []
    @State private var transferAmount: Double = 0
    @State private var recipient: String = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Баланс")) {
                    Text("\(accounts[0].balance) ₽")
                }

                Section(header: Text("Транзакции")) {
                    ForEach(transactions, id: \.id) { transaction in
                        Text("\(transaction.recipient): \(transaction.amount) ₽ on \(transaction.date)")
                    }
                }

                Section(header: Text("Перевод")) {
                    TextField("Получатель", text: $recipient)
                    TextField("Сумма", value: $transferAmount, formatter: NumberFormatter())

                    Button("Отправить") {
                        let newTransaction = Transaction(amount: transferAmount, recipient: recipient, date: Date())
                        transactions.append(newTransaction)
                        accounts[0].balance -= transferAmount
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Мой банк")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
