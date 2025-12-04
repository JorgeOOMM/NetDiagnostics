//
//  ViewModifier+ScaledFont.swift
//  NetDiagnostics
//
//  Created by Mac on 3/12/25.
//
import SwiftUI

struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory)
    var sizeCategory
    var name: String
    var size: Double
    
    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom(name, size: scaledSize))
    }
}

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func scaledFont(name: String, size: Double) -> some View {
        self.modifier(ScaledFont(name: name, size: size))
    }
}
