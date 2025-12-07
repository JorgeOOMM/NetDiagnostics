//
//  BorderShineView.swift
//  NetDiagnostics
//
//  Created by Mac on 7/12/25.
//  Note: shine-effect-in-swiftui
//

import SwiftUI

// MARK: BorderShineView
struct BorderShineView: View {
    @State private var rotation: Double = 0.0
    @State private var animate: Bool = false
    
    var gradient: Gradient {
        Gradient(
            colors:
                [
                    .clear,
                    .clear,
                    .white.opacity(0.3),
                    .white,
                    .white.opacity(0.3),
                    .clear,
                    .clear
                ]
        )
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Rectangle().stroke(.black, lineWidth: 5)
                
                LinearGradient(gradient: self.gradient, startPoint: .leading, endPoint: .trailing)
                    .rotationEffect(.degrees(rotation))
                    .offset(x: -proxy.size.width)
                    .offset(x: animate ? proxy.size.width * 2 : -proxy.size.width)
                    .mask {
                        Rectangle().stroke(.black, lineWidth: 5)
                    }
            }
            .onAppear {
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
        }
    }
}

#Preview {
    BorderShineView().frame(width: 100, height: 100)
}
