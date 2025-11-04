//
//  AuthenticationViewModel.swift
//  wallet
//
//  Created by Codex on 24.03.2024.
//

import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var pinInput: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var showError: Bool = false
    @Published var isPresentingPin: Bool = true

    let requiredPin: String
    private let pinLength: Int
    private let authenticationService: AuthenticationServiceProtocol

    init(requiredPin: String = "1234",
         pinLength: Int = 4,
         authenticationService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.requiredPin = requiredPin
        self.pinLength = pinLength
        self.authenticationService = authenticationService
    }

    func handle(digit: Int) {
        guard pinInput.count < pinLength else { return }
        pinInput.append("\(digit)")
        validatePinIfNeeded()
    }

    func clear() {
        pinInput = ""
    }

    func backspace() {
        guard !pinInput.isEmpty else { return }
        pinInput.removeLast()
    }

    func tryBiometricUnlock() async {
        let success = await authenticationService.authenticateWithBiometrics(reason: "Разблокируйте кошелек")
        if success {
            markAuthenticated()
        }
    }

    private func validatePinIfNeeded() {
        guard pinInput.count == pinLength else { return }
        if pinInput == requiredPin {
            markAuthenticated()
        } else {
            showError = true
            pinInput = ""
        }
    }

    private func markAuthenticated() {
        isAuthenticated = true
        isPresentingPin = false
        showError = false
    }
}
