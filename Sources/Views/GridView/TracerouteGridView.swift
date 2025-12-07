//
//  TracerouteGridView.swift
//  NetDiagnostics
//
//  Created by Mac on 7/12/25.
//

import SwiftUI

// MARK: TracerouteGridView
struct TracerouteGridView: View {
    var route: [[NetResponse]]
    let columns = [
        GridItem(.adaptive(minimum: 30, maximum: 30)),
        GridItem(.flexible(minimum: 150, maximum: .infinity)),
        GridItem(.flexible(minimum: 60, maximum: 60)),
        GridItem(.flexible(minimum: 60, maximum: 60)),
        GridItem(.flexible(minimum: 60, maximum: 60))
    ]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                // Add the Grid Header
                GridRow {
                    GridCellView(value: "Hop")  // Hop Number
                    GridCellView(value: "From") // Hop Details
                    GridCellView(value: "RTT1") // Round Trip Time Attempt 1
                    GridCellView(value: "RTT2") // Round Trip Time Attempt 2
                    GridCellView(value: "RTT3") // Round Trip Time Attempt 3
                }
                
                ForEach(route.indices, id: \.self) { index in
                    let hop = route[index]
                    let hopIndex = index+1
                    if hop.count == 3 {
                        GridRow {
                            GridCellView(value: "\(hopIndex)")
                            GridCellView(value: "\(hop[0].from)")
                            GridCellView(value: hop[0].rtt.millisecsString)
                            GridCellView(value: hop[1].rtt.millisecsString)
                            GridCellView(value: hop[2].rtt.millisecsString)
                        }
                    } else {
                        
                        if hop.count == 2 {
                            GridRow {
                                GridCellView(value: "\(hopIndex)")
                                GridCellView(value: "\(hop[0].from)")
                                GridCellView(value: hop[0].rtt.millisecsString)
                                GridCellView(value: hop[1].rtt.millisecsString)
                                GridCellView(value: "")
                            }
                        } else {
                            if hop.count == 1 {
                                GridRow {
                                    GridCellView(value: "\(hopIndex)")
                                    GridCellView(value: "\(hop[0].from)")
                                    GridCellView(value: hop[0].rtt.millisecsString)
                                    GridCellView(value: "")
                                    GridCellView(value: "")
                                }
                            } else {
                                GridRow {
                                    GridCellView(value: "\(hopIndex)")
                                    GridCellView(value: "")
                                    GridCellView(value: "")
                                    GridCellView(value: "")
                                    GridCellView(value: "")
                                }
                            }
                        }
                    }
                }
                
            } .padding(.horizontal)
        }
    }
}
