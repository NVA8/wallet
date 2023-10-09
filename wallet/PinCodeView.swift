//
//  PinCodeView.swift
//  wallet
//
//  Created by Валерий Никитин on 09.10.2023.
//

import SwiftUI

struct PinCodeView: View {
    @Binding var isPresented: Bool
    @Binding var passwordInput: String
    @State private var showErrorAlert: Bool = false
    let correctPassword: String
    let onAuthenticated: () -> Void
    private let pinLength = 4

    var body: some View {
        VStack(spacing: 20) {
            Text("Введите пароль")
            
            if showErrorAlert {
                Text("Введен неверный пароль!")
                    .foregroundColor(.red)
                    .padding()
            }

            HStack {
                ForEach(0..<pinLength) { index in
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(passwordInput.count > index ? .blue : .gray)
                }
            }
            
            VStack(spacing: 10) {
                ForEach(1...3, id: \.self) { row in
                    HStack(spacing: 60) {
                        ForEach(1...3, id: \.self) { col in
                            let number = col + (row - 1) * 3
                            numberButton(number: number)
                        }
                    }
                }
                numberButton(number: 0)
            }
            .padding()
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Ошибка"),
                  message: Text("Введен неверный пароль, правильный 1234"),
                  dismissButton: .default(Text("Попробовать еще раз")))
        }
    }
    
    func numberButton(number: Int) -> some View {
        return Button(action: {
            if passwordInput.count < pinLength {
                passwordInput.append("\(number)")
                checkPassword()
            }
        }) {
            Text("\(number)")
                .font(.largeTitle)
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(0.2))
                .clipShape(Circle())
        }
    }

    func checkPassword() {
        if passwordInput.count == pinLength {
            if passwordInput == correctPassword {
                onAuthenticated()
                isPresented = false
            } else {
                passwordInput = ""
                showErrorAlert = true
            }
        }
    }
}
