//
//  AuthenticationService.swift
//  wallet
//
//  Created by Codex on 24.03.2024.
//

import Foundation
import LocalAuthentication

protocol AuthenticationServiceProtocol {
    func authenticateWithBiometrics(reason: String) async -> Bool
}

final class AuthenticationService: AuthenticationServiceProtocol {
    func authenticateWithBiometrics(reason: String) async -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }

        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                continuation.resume(returning: success)
            }
        }
    }
}
