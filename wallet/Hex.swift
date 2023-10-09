//
//  Hex.swift
//  wallet
//
//  Created by Валерий Никитин on 09.10.2023.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexSanitized)
        
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            let red = Double((hexNumber & 0xFF0000) >> 16) / 255
            let green = Double((hexNumber & 0x00FF00) >> 8) / 255
            let blue = Double(hexNumber & 0x0000FF) / 255

            self.init(red: red, green: green, blue: blue)
        } else {
            self.init(UIColor.gray) // If scanning the hex value fails, we default to gray
        }
    }
}
