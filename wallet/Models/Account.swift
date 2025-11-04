//
//  Account.swift
//  wallet
//
//  Created by Codex on 24.03.2024.
//

import Foundation

struct Account: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var currency: Currency
    var balance: Double
    var icon: String
    var colorHex: String

    init(id: UUID = UUID(),
         name: String,
         currency: Currency,
         balance: Double,
         icon: String = "wallet.pass",
         colorHex: String = "1D1F2F") {
        self.id = id
        self.name = name
        self.currency = currency
        self.balance = balance
        self.icon = icon
        self.colorHex = colorHex
    }
}

extension Account {
    static let previewData: [Account] = [
        Account(name: "Основной счет", currency: Currency.by(code: "RUB") ?? Currency.all[0], balance: 125_000, icon: "r.circle.fill", colorHex: "3178C6"),
        Account(name: "USD Savings", currency: Currency.by(code: "USD") ?? Currency.all[0], balance: 4_200, icon: "dollarsign.circle.fill", colorHex: "2E7D32"),
        Account(name: "BTC Vault", currency: Currency.by(code: "BTC") ?? Currency.all[5], balance: 0.75, icon: "bitcoinsign.circle.fill", colorHex: "F7931A"),
        Account(name: "ETH Staking", currency: Currency.by(code: "ETH") ?? Currency.all[6], balance: 12.3, icon: "e.circle.fill", colorHex: "4F5B93")
    ]
}
