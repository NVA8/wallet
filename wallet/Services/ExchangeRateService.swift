//
//  ExchangeRateService.swift
//  wallet
//
//  Created by Codex on 24.03.2024.
//

import Foundation

protocol ExchangeRateServiceProtocol {
    func convert(amount: Double, from source: Currency, to target: Currency) -> Double
    func rate(from source: Currency, to target: Currency) -> Double
    func availableCurrencies() -> [Currency]
}

final class ExchangeRateService: ExchangeRateServiceProtocol {
    private var baseCurrencyCode: String
    private var rates: [String: Double]

    init(baseCurrencyCode: String = "USD") {
        self.baseCurrencyCode = baseCurrencyCode
        self.rates = [
            "USD": 1.0,
            "EUR": 1.08,
            "RUB": 0.011,
            "GBP": 1.27,
            "CHF": 1.10,
            "BTC": 67_500,
            "ETH": 3_500,
            "USDT": 1.0,
            "BNB": 310,
            "SOL": 105
        ]
    }

    func availableCurrencies() -> [Currency] {
        Currency.all
    }

    func update(rate: Double, for currencyCode: String) {
        rates[currencyCode] = rate
    }

    func convert(amount: Double, from source: Currency, to target: Currency) -> Double {
        guard amount != 0 else { return 0 }
        let baseAmount = amount * rateToBase(code: source.code)
        let targetAmount = baseAmount / rateToBase(code: target.code)
        return targetAmount
    }

    func rate(from source: Currency, to target: Currency) -> Double {
        convert(amount: 1, from: source, to: target)
    }

    private func rateToBase(code: String) -> Double {
        guard let rate = rates[code] else { return 1 }
        return rate / (rates[baseCurrencyCode] ?? 1)
    }
}
