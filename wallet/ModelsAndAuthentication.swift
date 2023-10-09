//
//  ModelsAndAuthentication.swift
//  wallet
//
//  Created by Валерий Никитин on 08.10.2023.
//

import Foundation
import SwiftUI
import LocalAuthentication

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

func authenticateUser(completion: @escaping (Bool) -> Void) {
    let context = LAContext()
    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        let reason = "Идентифицируйтесь, чтобы продолжить."

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
            DispatchQueue.main.async {
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    } else {
        completion(false)
    }
}
