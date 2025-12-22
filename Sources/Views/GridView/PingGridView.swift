//
//  PingGridView.swift
//  NetDiagnostics
//
//  Created by Mac on 7/12/25.
//

import SwiftUI

// MARK: PingGridView
struct PingGridView: View {
    var pings: [NetResponse]
    let columns = [
        GridItem(.flexible(minimum: 30, maximum: 30)),
        GridItem(.flexible(minimum: 165, maximum: .infinity)),
        GridItem(.flexible(minimum: 30, maximum: 30)),
        GridItem(.flexible(minimum: 30, maximum: 30)),
        GridItem(.flexible(minimum: 65, maximum: 65))
    ]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing:0) {
                // Add the Grid Header
                GridRow {
                    GridCellView(value: "Len")
                    GridCellView(value: "From")
                    GridCellView(value: "Seq")
                    GridCellView(value: "TTL")
                    GridCellView(value: "ms")
                }
                ForEach(pings) { item in
                    GridRow {
                        GridCellView(value: "\(item.len)")
                        GridCellView(value: "\(item.from)")
                        GridCellView(value: "\(item.sequence)")
                        GridCellView(value: "\(item.hopLimit)")
                        GridCellView(value: item.rtt.millisecsString)
                    }
                }
            }.padding(.leading, 0)
        }
    }
}
