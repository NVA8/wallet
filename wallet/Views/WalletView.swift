//
//  WalletView.swift
//  wallet
//
//  Created by Codex on 24.03.2024.
//

import SwiftUI

struct WalletView: View {
    @StateObject private var viewModel = WalletViewModel()
    @State private var showAddAccount = false
    @State private var accountForDeposit: Account?
    @State private var depositAmount: String = ""
    @State private var depositNote: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    totalsCard
                    accountsSection
                    transferSection
                    transactionsSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color(hex: "E5E5E5").ignoresSafeArea())
            .navigationTitle("Мой кошелёк")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddAccount.toggle()
                    } label: {
                        Label("Добавить счёт", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddAccount) {
            AddAccountView(viewModel: viewModel)
        }
        .sheet(item: $accountForDeposit, onDismiss: {
            depositAmount = ""
            depositNote = ""
        }) { account in
            DepositView(account: account,
                        amount: $depositAmount,
                        note: $depositNote,
                        onCommit: { amount, note in
                            viewModel.deposit(to: account.id, amountString: amount, note: note)
                            accountForDeposit = nil
                        })
        }
        .alert(item: $viewModel.lastError) { error in
            Alert(title: Text("Ошибка"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK")))
        }
    }

    private var totalsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Итоговые активы")
                .font(.headline)
            HStack {
                summaryMetric(title: "Fiat", amount: viewModel.summary.fiatTotal, currency: viewModel.summary.baseCode)
                summaryMetric(title: "Crypto", amount: viewModel.summary.cryptoTotalInBase, currency: viewModel.summary.baseCode)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    private var accountsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Счета")
                .font(.headline)
            ForEach(viewModel.accounts) { account in
                AccountCard(account: account,
                            isSelected: account.id == viewModel.selectedAccountId,
                            onSelect: { viewModel.selectAccount(id: account.id) },
                            onDeposit: {
                                accountForDeposit = account
                                depositAmount = ""
                                depositNote = ""
                            })
            }
        }
    }

    private var transferSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Перевод")
                .font(.headline)

            Picker("Счёт списания", selection: $viewModel.selectedAccountId) {
                Text("Выберите счёт").tag(Optional<UUID>.none)
                ForEach(viewModel.accounts) { account in
                    Text("\(account.name) (\(account.currency.code))").tag(Optional(account.id))
                }
            }
            .pickerStyle(.menu)

            TextField("Сумма", text: $viewModel.transferDraft.amount)
                .keyboardType(.decimalPad)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.blue.opacity(0.3)))

            Menu {
                if viewModel.isLoadingContacts {
                    ProgressView()
                } else if viewModel.contacts.isEmpty {
                    Text("Контакты не найдены")
                } else {
                    ForEach(viewModel.contacts) { contact in
                        Button(contact.displayName) {
                            viewModel.transferDraft.recipientName = contact.displayName
                        }
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.transferDraft.recipientName.isEmpty ? "Выбрать получателя" : viewModel.transferDraft.recipientName)
                        .foregroundColor(viewModel.transferDraft.recipientName.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.blue.opacity(0.3)))
            }

            TextField("Комментарий (необязательно)", text: $viewModel.transferDraft.note)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.blue.opacity(0.3)))

            Button {
                viewModel.sendFunds()
            } label: {
                Text("Отправить")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("История операций")
                .font(.headline)
            if viewModel.transactions.isEmpty {
                Text("Нет операций")
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.transactions.prefix(10)) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    private func summaryMetric(title: String, amount: Double, currency: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(String(format: "%.2f %@", amount, currency))
                .font(.title2.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct AccountCard: View {
    let account: Account
    let isSelected: Bool
    let onSelect: () -> Void
    let onDeposit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: account.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: account.colorHex))
                VStack(alignment: .leading) {
                    Text(account.name)
                        .font(.headline)
                    Text(account.currency.assetClass == .fiat ? "Фиат" : "Крипто")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(account.currency.symbol) \(formattedAmount(account.balance, precision: account.currency.precision))")
                    .font(.headline)
            }
            HStack {
                Button(action: onSelect) {
                    Label(isSelected ? "Выбран" : "Выбрать", systemImage: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)

                Button(action: onDeposit) {
                    Label("Пополнить", systemImage: "arrow.down.circle")
                        .font(.subheadline)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: account.colorHex))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

private struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.direction == .incoming ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill")
                .foregroundColor(transaction.direction == .incoming ? .green : .red)
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.counterparty)
                    .font(.headline)
                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(transaction.direction == .incoming ? "+" : "-")\(transaction.currency.symbol) \(formattedAmount(transaction.amount, precision: transaction.currency.precision))")
                    .font(.headline)
                    .foregroundColor(transaction.direction == .incoming ? .green : .red)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

private struct DepositView: View {
    let account: Account
    @Binding var amount: String
    @Binding var note: String

    let onCommit: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Счёт")) {
                    Text(account.name)
                    Text("Текущий баланс: \(account.currency.symbol) \(formattedAmount(account.balance, precision: account.currency.precision))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Section(header: Text("Пополнение")) {
                    TextField("Сумма", text: $amount)
                        .keyboardType(.decimalPad)
                    TextField("Комментарий", text: $note)
                }
            }
            .navigationTitle("Пополнение")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        onCommit(amount, note)
                        dismiss()
                    }
                    .disabled(amount.isEmpty)
                }
            }
        }
    }
}

private struct AddAccountView: View {
    @ObservedObject var viewModel: WalletViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAssetClass: AssetClass = .fiat

    private var filteredCurrencies: [Currency] {
        Currency.all.filter { $0.assetClass == selectedAssetClass }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Тип актива")) {
                    Picker("Тип", selection: $selectedAssetClass) {
                        ForEach(AssetClass.allCases, id: \.self) { asset in
                            Text(asset == .fiat ? "Фиат" : "Крипто").tag(asset)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section(header: Text("Основное")) {
                    TextField("Название", text: $viewModel.accountDraft.name)
                    Picker("Валюта", selection: $viewModel.accountDraft.currency) {
                        ForEach(filteredCurrencies, id: \.self) { currency in
                            Text("\(currency.name) (\(currency.code))").tag(currency)
                        }
                    }
                }
                Section(header: Text("Баланс")) {
                    TextField("Начальный баланс", text: $viewModel.accountDraft.initialBalance)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Оформление")) {
                    TextField("SF Symbol", text: $viewModel.accountDraft.icon)
                    TextField("Цвет в HEX", text: $viewModel.accountDraft.colorHex)
                }
            }
            .navigationTitle("Новый счёт")
            .onAppear {
                selectedAssetClass = viewModel.accountDraft.currency.assetClass
            }
            .onChange(of: selectedAssetClass) { newValue in
                if viewModel.accountDraft.currency.assetClass != newValue {
                    viewModel.accountDraft.currency = filteredCurrencies.first ?? viewModel.accountDraft.currency
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        viewModel.addAccount()
                        dismiss()
                    }
                    .disabled(viewModel.accountDraft.name.isEmpty)
                }
            }
        }
    }
}

private func formattedAmount(_ value: Double, precision: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = precision
    return formatter.string(from: NSNumber(value: value)) ?? String(value)
}
