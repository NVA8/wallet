//
//  WalletViewModel.swift
//  wallet
//
//  Created by Codex on 24.03.2024.
//

import Foundation

struct TransferDraft {
    var amount: String = ""
    var recipientName: String = ""
    var note: String = ""
}

struct AccountDraft {
    var name: String = ""
    var currency: Currency = Currency.all.first ?? Currency(code: "USD",
                                                            name: "US Dollar",
                                                            symbol: "$",
                                                            assetClass: .fiat,
                                                            precision: 2)
    var initialBalance: String = ""
    var icon: String = "wallet.pass"
    var colorHex: String = "1D1F2F"
}

enum WalletError: LocalizedError, Identifiable {
    case invalidAmount
    case amountExceedsBalance
    case accountMissing

    var id: String { localizedDescription }

    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Введите корректную сумму."
        case .amountExceedsBalance:
            return "Недостаточно средств."
        case .accountMissing:
            return "Не выбран счёт."
        }
    }
}

@MainActor
final class WalletViewModel: ObservableObject {
    @Published var accounts: [Account]
    @Published var transactions: [Transaction]
    @Published var contacts: [WalletContact] = []
    @Published var selectedAccountId: UUID?
    @Published var transferDraft = TransferDraft()
    @Published var accountDraft = AccountDraft()
    @Published var lastError: WalletError?
    @Published var isLoadingContacts = false

    private let contactService: ContactServiceProtocol
    private let exchangeService: ExchangeRateServiceProtocol

    init(contactService: ContactServiceProtocol = ContactService(),
         exchangeService: ExchangeRateServiceProtocol = ExchangeRateService()) {
        self.contactService = contactService
        self.exchangeService = exchangeService
        let initialAccounts = Account.previewData
        self.accounts = initialAccounts
        self.transactions = Transaction.makeSample(accounts: initialAccounts)
        self.selectedAccountId = initialAccounts.first?.id
        Task { await loadContactsIfAuthorized() }
    }

    var selectedAccount: Account? {
        guard let id = selectedAccountId else { return nil }
        return accounts.first { $0.id == id }
    }

    var summary: WalletSummary {
        WalletSummary(accounts: accounts, exchangeService: exchangeService)
    }

    func selectAccount(id: UUID) {
        selectedAccountId = id
    }

    func loadContactsIfAuthorized() async {
        isLoadingContacts = true
        defer { isLoadingContacts = false }
        guard await contactService.requestAccess() else {
            contacts = []
            return
        }
        contacts = await contactService.fetchContacts()
    }

    func sendFunds() {
        guard let accountIndex = accounts.firstIndex(where: { $0.id == selectedAccountId }) else {
            lastError = .accountMissing
            return
        }

        guard let amount = Double(transferDraft.amount.replacingOccurrences(of: ",", with: ".")), amount > 0 else {
            lastError = .invalidAmount
            return
        }

        guard accounts[accountIndex].balance >= amount else {
            lastError = .amountExceedsBalance
            return
        }

        accounts[accountIndex].balance -= amount
        let account = accounts[accountIndex]

        let transaction = Transaction(accountId: account.id,
                                      amount: amount,
                                      currency: account.currency,
                                      direction: .outgoing,
                                      counterparty: transferDraft.recipientName.isEmpty ? "Неизвестный" : transferDraft.recipientName,
                                      category: "Перевод",
                                      note: transferDraft.note)
        transactions.insert(transaction, at: 0)
        transferDraft = TransferDraft()
    }

    func deposit(to accountId: UUID, amountString: String, note: String) {
        guard let amount = Double(amountString.replacingOccurrences(of: ",", with: ".")), amount > 0 else {
            lastError = .invalidAmount
            return
        }
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else {
            lastError = .accountMissing
            return
        }

        accounts[index].balance += amount
        let account = accounts[index]
        let transaction = Transaction(accountId: accountId,
                                      amount: amount,
                                      currency: account.currency,
                                      direction: .incoming,
                                      counterparty: "Пополнение",
                                      category: "Пополнение",
                                      note: note)
        transactions.insert(transaction, at: 0)
    }

    func addAccount() {
        let balance = Double(accountDraft.initialBalance.replacingOccurrences(of: ",", with: ".")) ?? 0
        let newAccount = Account(name: accountDraft.name.isEmpty ? "Новый счёт" : accountDraft.name,
                                 currency: accountDraft.currency,
                                 balance: balance,
                                 icon: accountDraft.icon,
                                 colorHex: accountDraft.colorHex)
        accounts.append(newAccount)
        selectedAccountId = newAccount.id
        accountDraft = AccountDraft()
    }
}

struct WalletSummary {
    let fiatTotal: Double
    let cryptoTotalInBase: Double
    let baseCurrency: Currency
    let baseCode: String

    init(accounts: [Account], exchangeService: ExchangeRateServiceProtocol, baseCurrency: Currency = Currency.by(code: "USD") ?? Currency.all[0]) {
        self.baseCurrency = baseCurrency
        baseCode = baseCurrency.code

        var fiatSum: Double = 0
        var cryptoSum: Double = 0

        for account in accounts {
            switch account.currency.assetClass {
            case .fiat:
                let converted = exchangeService.convert(amount: account.balance, from: account.currency, to: baseCurrency)
                fiatSum += converted
            case .crypto:
                let converted = exchangeService.convert(amount: account.balance, from: account.currency, to: baseCurrency)
                cryptoSum += converted
            }
        }
        fiatTotal = fiatSum
        cryptoTotalInBase = cryptoSum
    }
}
