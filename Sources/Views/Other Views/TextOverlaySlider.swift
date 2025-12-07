//
//  TextOverlaySlider.swift
//  NetDiagnostics
//
//  Created by Mac on 5/12/25.
//  Note: overlay-text-not-centered-while-moving-along-with-the-slider-thumb-alignment-i
//

import SwiftUI

var defaultSize: CGFloat = {
#if os(macOS)
    20
#else
    28
#endif
}()

// MARK: SliderLabel
struct SliderLabel: View {
    var value: Float
    var body: some View {
        Text(value, format: .number.precision(.fractionLength(1)))
            .font(Font.body.lowercaseSmallCaps())
    }
}

// MARK: TextOverlaySlider
struct TextOverlaySlider: View {
    @Binding var value: Float
    var range: ClosedRange<Float> = 0...10
    var step: Float.Stride
    @State private var isEditing = false
    
    var body: some View {
        ZStack {
            // Consider this a a placeholder of the slider
            Capsule()
                .stroke(borderStyle(), lineWidth: 2.0)
                .frame(height: defaultSize)
            HStack {
                SliderLabel(value: range.lowerBound)
                LinearGradient(
                    gradient: Gradient(colors: [.white, .mint, .teal, .cyan, .blue, .indigo]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(
                    Slider(
                        value: $value, in: range, step: step
                    )
                )
                SliderLabel(value: range.upperBound)
            }
            .frame(height: defaultSize)
            .padding(.horizontal)
            HStack {
                SliderLabel(value: range.lowerBound)
                // Dummy replicated slider, to allow sliding
                Slider(
                    value: $value, in: range, step: step
                ) { value in
                    isEditing = value
                }
                .accentColor(.clear)
                .overlay {
                    if isEditing {
                        GeometryReader { proxy in
                            let width = proxy.size.width
                            let height = proxy.size.height
                            let approxButtonWidth = ratioButtonWidthToSliderHeight * height
                            let lenght = range.upperBound - range.lowerBound
                            let xOffset = CGFloat((value - range.lowerBound - (lenght / 2)) / lenght) * (width - approxButtonWidth)
                            let yOffset = (approxButtonWidth / 2) / 2
                            if value != range.lowerBound && value != range.upperBound {
                                Text(value, format: .number.precision(.fractionLength(1)))
                                    .foregroundStyle(.black)
                                    .font(.body.monospacedDigit())
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                    .background {
                                        Circle()
                                            .fill(.white.opacity(0.3))
                                    }
                                    .fixedSize()
                                    .frame(maxWidth: .infinity, maxHeight: height, alignment: .bottom)
                                    .offset(x: xOffset, y: yOffset)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .opacity.animation(.easeInOut(duration: 0.1)),
                            removal: .opacity.animation(.easeInOut.delay(0.1))
                        ))
                    }
                }
                // instead setting opacity,
                // setting clear color is another alternative
                // slider's circle remains white in this case
                SliderLabel(value: range.upperBound)
            }.frame(height: defaultSize)
             .padding(.horizontal)
        }
    }
    
    private var ratioButtonWidthToSliderHeight: CGFloat {
        if #available(iOS 26.0, *) {
            1.2
        } else {
            0.9
        }
    }
}

extension TextOverlaySlider {
    func borderStyle() -> some ShapeStyle {
        LinearGradient(colors: [.white.opacity(0.5), .gray.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}


// MARK: NameTextOverlaySlider
struct NameTextOverlaySlider: View {
    
    var name: String
    var value: Binding<Float>
    var minValue: Float
    var maxValue: Float
    var step: Float
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .padding(.leading, 4)
            Spacer()
            TextOverlaySlider(value: value, range: minValue...maxValue, step: step)
            Spacer()
        }
    }
}

#Preview {
    @Previewable @State var value: Float = 0
    @Previewable @State var value2: Float = 0
    TextOverlaySlider(value: $value, range: 0...100, step: 1.0)
    Divider()
    NameTextOverlaySlider(name: "Name", value: $value2, minValue: 0, maxValue: 100, step: 1.0)
}
