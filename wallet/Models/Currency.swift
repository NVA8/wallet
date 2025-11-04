//
//  Currency.swift
//  wallet
//
//  Created by Codex on 24.03.2024.
//

import Foundation

enum AssetClass: String, CaseIterable, Codable {
    case fiat
    case crypto
}

struct Currency: Identifiable, Hashable, Codable {
    let id = UUID()
    let code: String
    let name: String
    let symbol: String
    let assetClass: AssetClass
    let precision: Int

    static let all: [Currency] = [
        Currency(code: "USD", name: "US Dollar", symbol: "$", assetClass: .fiat, precision: 2),
        Currency(code: "EUR", name: "Euro", symbol: "€", assetClass: .fiat, precision: 2),
        Currency(code: "RUB", name: "Russian Ruble", symbol: "₽", assetClass: .fiat, precision: 2),
        Currency(code: "GBP", name: "British Pound", symbol: "£", assetClass: .fiat, precision: 2),
        Currency(code: "CHF", name: "Swiss Franc", symbol: "₣", assetClass: .fiat, precision: 2),
        Currency(code: "BTC", name: "Bitcoin", symbol: "₿", assetClass: .crypto, precision: 8),
        Currency(code: "ETH", name: "Ethereum", symbol: "Ξ", assetClass: .crypto, precision: 6),
        Currency(code: "USDT", name: "Tether", symbol: "₮", assetClass: .crypto, precision: 2),
        Currency(code: "BNB", name: "Binance Coin", symbol: "Ⓑ", assetClass: .crypto, precision: 6),
        Currency(code: "SOL", name: "Solana", symbol: "◎", assetClass: .crypto, precision: 6)
    ]

    static func by(code: String) -> Currency? {
        Currency.all.first { $0.code == code }
    }
}

extension Currency {
    var formattedCode: String { "\(symbol) \(code)" }
}
