//
//  GridCellViewProtocol.swift
//  NetDiagnostics
//
//  Created by Mac on 7/12/25.
//

import SwiftUI
 
// MARK: GridCellViewProtocol
protocol GridCellViewProtocol {
    associatedtype CellViewType: View
    
    var value: String {get}
    var body: CellViewType {get}
}

extension GridCellViewProtocol {
    var body: some View {
        //VStack(alignment: .leading) {
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.black)
        //}
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(5)
    }
}

// MARK: GridCellView
struct GridCellView: View, GridCellViewProtocol {
    var value: String
}
