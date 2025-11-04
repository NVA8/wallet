//
//  ContactService.swift
//  wallet
//
//  Created by Codex on 24.03.2024.
//

import Foundation
import Contacts

struct WalletContact: Identifiable, Hashable {
    let id: String
    let displayName: String

    init(contact: CNContact) {
        id = contact.identifier
        let given = contact.givenName.trimmingCharacters(in: .whitespaces)
        let family = contact.familyName.trimmingCharacters(in: .whitespaces)
        let fullName = "\(given) \(family)".trimmingCharacters(in: .whitespaces)
        displayName = fullName.isEmpty ? "Контакт без имени" : fullName
    }
}

protocol ContactServiceProtocol {
    func requestAccess() async -> Bool
    func fetchContacts() async -> [WalletContact]
}

final class ContactService: ContactServiceProtocol {
    private let store = CNContactStore()

    func requestAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            store.requestAccess(for: .contacts) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }

    func fetchContacts() async -> [WalletContact] {
        let keysToFetch: [CNKeyDescriptor] = [CNContactGivenNameKey as CNKeyDescriptor,
                                              CNContactFamilyNameKey as CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        var collected = [WalletContact]()
        do {
            try store.enumerateContacts(with: request) { contact, _ in
                collected.append(WalletContact(contact: contact))
            }
        } catch {
            print("Failed to enumerate contacts: \(error)")
        }
        return collected.sorted { $0.displayName < $1.displayName }
    }
}
