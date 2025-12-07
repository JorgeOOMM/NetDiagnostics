//
//  GridCellViewProtocol.swift
//  NetDiagnostics
//
//  Created by Mac on 7/12/25.
//

import SwiftUI
 
// MARK: GridCellViewProtocol
protocol GridCellViewProtocol {
    var value: String {get}
    associatedtype AssocType: View
    
    var body: AssocType {get}
}

extension GridCellViewProtocol {
    var body: some View {
        VStack(alignment: .center) {
            if value.isEmpty {
                BorderShineView()
            } else {
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(5)
    }
}

// MARK: GridCellView
struct GridCellView: View, GridCellViewProtocol {
    var value: String
}
