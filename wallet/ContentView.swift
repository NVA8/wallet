//
//  ContentView.swift
//  wallet
//
//  Created by Валерий Никитин on 08.10.2023.
//

import SwiftUI
import Contacts


class ContactManager {
    func fetchContacts() -> [CNContact] {
        let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor]
        let store = CNContactStore()
        
        do {
            let contacts = try store.unifiedContacts(matching: NSPredicate(value: true), keysToFetch: keysToFetch)
            return contacts
        } catch {
            print("Error fetching contacts: \(error)")
            return []
        }
    }

    func requestForContactAccess(completion: @escaping (Bool) -> Void) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            completion(granted)
        }
    }
}

struct ContentView: View {
    @State private var accounts = [Account(balance: 1000)]
    @State private var contacts: [CNContact] = []
    @State private var isShowingContactPicker = false
    @State private var transactions: [Transaction] = []
    @State private var transferAmount: Double = 0
    @State private var recipient: String = ""
    @State private var isAuthenticated = false
    @State private var isShowingPasswordView = true  // Изменено на true
    @State private var passwordInput = ""
    let correctPassword = "1234"
    private let contactManager = ContactManager()

    
    var mainContent: some View {
        VStack(spacing: 15) {
            roundedRectangleContainer {
                Text("Баланс: \(Int(accounts[0].balance)) ₽")
            }
            
            roundedRectangleContainer {
                VStack(spacing: 10) {
                    Text("Транзакции")
                    ForEach(transactions, id: \.id) { transaction in
                        Text("\(transaction.recipient): \(transaction.amount) ₽ on \(transaction.date)")
                    }
                }
            }
            roundedRectangleContainer {
                VStack(spacing: 10) {
                    Text("Перевод")

                    if isShowingContactPicker {
                        Picker("Выберите получателя", selection: $recipient) {
                            ForEach(contacts, id: \.identifier) { contact in
                                Text("\(contact.givenName) \(contact.familyName)").tag("\(contact.givenName) \(contact.familyName)")
                            }
                        }
                        .onAppear(perform: {
                            contactManager.requestForContactAccess { granted in
                                if granted {
                                    contacts = contactManager.fetchContacts()
                                }
                            }
                        })
                    } else {
                        Button("Выбрать из контактов") {
                            isShowingContactPicker.toggle()
                        }
                    }
                    TextField("Сумма", value: $transferAmount, formatter: NumberFormatter())
                        .padding() // Добавить отступ внутри текстового поля
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                        .padding([.top, .bottom])
                    Button(action: {
                        let newTransaction = Transaction(amount: transferAmount, recipient: recipient, date: Date())
                        transactions.append(newTransaction)
                        accounts[0].balance -= transferAmount
                    }) {
                        Text("Отправить")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding([.leading, .trailing], 10)
        .background(Color(hex: "E2E2E2"))
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Мой банк")
    }

    func roundedRectangleContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack {
            content()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    var authenticationRequiredView: some View {
        Text("Требуется аутентификация")  // Кнопка удалена
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "E2E2E2").edgesIgnoringSafeArea(.all)

                if isAuthenticated {
                    mainContent
                } else {
                    authenticationRequiredView
                }
            }
            .sheet(isPresented: $isShowingPasswordView) {
                PinCodeView(isPresented: $isShowingPasswordView, passwordInput: $passwordInput, correctPassword: correctPassword) {
                    isAuthenticated = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
