//
//  ContentView.swift
//  wallet
//
//  Created by Валерий Никитин on 08.10.2023.
//  Refactored to MVVM by Codex on 24.03.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some View {
        ZStack {
            WalletView()
                .blur(radius: authViewModel.isAuthenticated ? 0 : 12)
                .disabled(!authViewModel.isAuthenticated)
        }
        .sheet(isPresented: $authViewModel.isPresentingPin) {
            PinCodeView(viewModel: authViewModel)
        }
        .task {
            await authViewModel.tryBiometricUnlock()
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
