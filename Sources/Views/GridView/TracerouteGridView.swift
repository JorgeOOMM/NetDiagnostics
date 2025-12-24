//
//  TracerouteGridView.swift
//  NetDiagnostics
//
//  Created by Mac on 7/12/25.
//

import IPAddress2City
import SwiftUI

// MARK: TracerouteGridView
struct TracerouteGridView: View {
    var viewModel: ContentView.ViewModel
    let columns = [
        GridItem(.flexible(minimum: 35, maximum: 35)),
        GridItem(.flexible(minimum: 400, maximum: .infinity)),
        GridItem(.flexible(minimum: 30, maximum: 30)),
        GridItem(.flexible(minimum: 350, maximum: .infinity)),
        GridItem(.flexible(minimum: 200, maximum: .infinity)),
        GridItem(.flexible(minimum: 130, maximum: .infinity)),
        GridItem(.flexible(minimum: 70, maximum: 70)),
        GridItem(.flexible(minimum: 70, maximum: 70)),
        GridItem(.flexible(minimum: 70, maximum: 70))
    ]
    private let lookup = GeoAddressLookup()
    var header: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: 0
        ) {
            GridCellView(value: "Hop")       // Hop Number
            GridCellView(value: "From")      // Hop Details
            GridCellView(value: "")          // Flag
            GridCellView(value: "")          // Subdivision
            GridCellView(value: "")          // Subdivision2
            GridCellView(value: "")          // Country
            GridCellView(value: "RTT1")      // Round Trip Time Attempt 1
            GridCellView(value: "RTT2")      // Round Trip Time Attempt 2
            GridCellView(value: "RTT3")      // Round Trip Time Attempt 3
        }
    }

    var body: some View {
        ScrollView(.horizontal) {
            ScrollView(.vertical) {
                LazyVGrid(
                    columns: columns,
                    alignment: .leading,
                    spacing: 0,
                    pinnedViews: [.sectionHeaders]
                ) {
                    // Add the Grid Header
                    Section(header: header) {
                        ForEach(viewModel.route.indices, id: \.self) { index in
                            let hop = viewModel.route[index]
                            let hopIndex = index + 1
                            
                            if hop.isEmpty {
                                GridRow {
                                    GridCellView(value: "\(hopIndex)")
                                    GridCellView(value: "***")
                                    GridCellView(value: "***")
                                    GridCellView(value: "***")
                                    GridCellView(value: "***")
                                    GridCellView(value: "***")
                                    GridCellView(value: "***")
                                    GridCellView(value: "***")
                                    GridCellView(value: "***")
                                }
                            } else {
                                let from = "\(hop[0].from)"
                                let hostname = hop[0].from.hostName
                                let flag = try? lookup.flag(for: from)
                                let country = try? lookup.country(for: from)
                                let subdivision = try? lookup.subdivision(for: from)
                                let subdivision0 = subdivision?.components(separatedBy: " - ")[0]
                                let subdivision1 = subdivision?.components(separatedBy: " - ")[1]
        
                                if hop.count == 3 {
                                    GridRow {
                                        GridCellView(value: "\(hopIndex)")
                                        GridCellView(value: hostname ?? from)
                                        GridCellView(value: "\(flag ?? "")")
                                        GridCellView(value: "\(subdivision0 ?? "")")
                                        GridCellView(value: "\(subdivision1 ?? "")")
                                        GridCellView(value: "\(country ?? "")")
                                
                                        GridCellView(value: hop[0].rtt.millisecsString)
                                        GridCellView(value: hop[1].rtt.millisecsString)
                                        GridCellView(value: hop[2].rtt.millisecsString)
                                    }
                                } else if hop.count == 2 {
                                    GridRow {
                                        GridCellView(value: "\(hopIndex)")
                                        GridCellView(value: hostname ?? from)
                                        GridCellView(value: "\(flag ?? "")")
                                        GridCellView(value: "\(subdivision0 ?? "")")
                                        GridCellView(value: "\(subdivision1 ?? "")")
                                        GridCellView(value: "\(country ?? "")")
                                        
                                        GridCellView(value: hop[0].rtt.millisecsString)
                                        GridCellView(value: hop[1].rtt.millisecsString)
                                        GridCellView(value: "***")
                                    }
                                } else if hop.count == 1 {
                                    GridRow {
                                        GridCellView(value: "\(hopIndex)")
                                        GridCellView(value: hostname ?? from)
                                        GridCellView(value: "\(flag ?? "")")
                                        GridCellView(value: "\(subdivision0 ?? "")")
                                        GridCellView(value: "\(subdivision1 ?? "")")
                                        GridCellView(value: "\(country ?? "")")
                                        
                                        GridCellView(value: hop[0].rtt.millisecsString)
                                        GridCellView(value: "***")
                                        GridCellView(value: "***")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
