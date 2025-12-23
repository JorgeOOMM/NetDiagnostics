//
//  SliderLabel.swift
//  NetDiagnostics
//
//  Created by Mac on 22/12/25.
//

import SwiftUI

// MARK: SliderLabel
struct SliderLabel: View {
    var value: Float
    var body: some View {
        Text(value, format: .number.precision(.fractionLength(1)))
            .font(Font.caption.lowercaseSmallCaps())
    }
}
