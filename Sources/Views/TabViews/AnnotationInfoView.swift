//
//  AnnotationInfoView.swift
//  NetDiagnostics
//
//  Created by Mac on 4/1/26.
//

import SwiftUI

struct AnnotationInfoView: View {
    let place: MapLocation
    @State var placeButtonTapped: Bool = false
    @State var backgroundColor = Color.white
    @State var placeImage = Image(systemName: "network")
    @State var widthSize: CGFloat = .zero
    
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            HStack(spacing: .zero) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        placeButtonTapped.toggle()
                        widthSize = placeButtonTapped ? 50 : .zero
                    }
                } label: {
                    ZStack {
                        placeImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .cornerRadius(36)
                    }
                }
                .clipShape(Circle())
                .padding(2.0)
                .background(backgroundColor)
                .cornerRadius(36)
                
                Button {
                    
                } label: {
                    Text("info")
                }
                .frame(width: self.widthSize, height: 20)
            }
            .background(Color.white)
            .cornerRadius(CGFloat(36))
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.red)
                .frame(width: CGFloat(5), height: 10)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -3.5)
                .padding(.bottom, 20)
        }
    }
}
