//
//  PinCodeView.swift
//  wallet
//
//  Created by Валерий Никитин on 09.10.2023.
//  Refactored to MVVM by Codex on 24.03.2024.
//

import SwiftUI

struct PinCodeView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 24), count: 3)

    var body: some View {
        VStack(spacing: 24) {
            Text("Введите PIN-код")
                .font(.title3.weight(.semibold))

            if viewModel.showError {
                Text("Неверный PIN, попробуйте снова.")
                    .foregroundColor(.red)
                    .transition(.opacity)
            }

            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .frame(width: 16, height: 16)
                        .foregroundColor(index < viewModel.pinInput.count ? .blue : .gray.opacity(0.4))
                }
            }

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(1...9, id: \.self) { number in
                    numberButton(number: number)
                }
                biometricButton
                numberButton(number: 0)
                deleteButton
            }
            .padding(.horizontal, 24)
        }
        .padding()
        .interactiveDismissDisabled()
        .task {
            await viewModel.tryBiometricUnlock()
        }
    }

    private func numberButton(number: Int) -> some View {
        Button {
            viewModel.handle(digit: number)
        } label: {
            Text("\(number)")
                .font(.title)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Color.blue.opacity(0.15))
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var deleteButton: some View {
        Button {
            viewModel.backspace()
        } label: {
            Image(systemName: "delete.left")
                .font(.title2)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Color.gray.opacity(0.15))
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var biometricButton: some View {
        Button {
            Task { await viewModel.tryBiometricUnlock() }
        } label: {
            Image(systemName: "faceid")
                .font(.title2)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Color.green.opacity(0.15))
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
