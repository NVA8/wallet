//
//  Transaction.swift
//  wallet
//
//  Created by Codex on 24.03.2024.
//

import Foundation

enum TransactionDirection: String, Codable {
    case incoming
    case outgoing
}

struct Transaction: Identifiable, Hashable, Codable {
    let id: UUID
    let accountId: UUID
    let amount: Double
    let currency: Currency
    let direction: TransactionDirection
    let counterparty: String
    let category: String
    let note: String
    let date: Date

    init(id: UUID = UUID(),
         accountId: UUID,
         amount: Double,
         currency: Currency,
         direction: TransactionDirection,
         counterparty: String,
         category: String,
         note: String = "",
         date: Date = Date()) {
        self.id = id
        self.accountId = accountId
        self.amount = amount
        self.currency = currency
        self.direction = direction
        self.counterparty = counterparty
        self.category = category
        self.note = note
        self.date = date
    }
}

extension Transaction {
    static func makeSample(accounts: [Account]) -> [Transaction] {
        guard let rub = Currency.by(code: "RUB"), let usd = Currency.by(code: "USD"),
              let btc = Currency.by(code: "BTC"), let first = accounts.first else {
            return []
        }

        let rubAccountId = accounts.first(where: { $0.currency.code == "RUB" })?.id ?? first.id
        let usdAccountId = accounts.first(where: { $0.currency.code == "USD" })?.id ?? first.id
        let btcAccountId = accounts.first(where: { $0.currency.code == "BTC" })?.id ?? first.id

        return [
            Transaction(accountId: rubAccountId, amount: 3500, currency: rub, direction: .outgoing, counterparty: "Delivery Club", category: "Еда", note: "Ужин"),
            Transaction(accountId: usdAccountId, amount: 250, currency: usd, direction: .incoming, counterparty: "Upwork", category: "Фриланс"),
            Transaction(accountId: btcAccountId, amount: 0.15, currency: btc, direction: .incoming, counterparty: "Coinbase Earn", category: "Крипто-доход"),
            Transaction(accountId: rubAccountId, amount: 12000, currency: rub, direction: .outgoing, counterparty: "Авиабилеты", category: "Путешествия"),
            Transaction(accountId: usdAccountId, amount: 130, currency: usd, direction: .outgoing, counterparty: "Digital Ocean", category: "Облако", note: "Продление VPS")
        ]
    }
}
