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
        GridItem(.fixed(35), alignment: .leading),
        GridItem(.fixed(130), alignment: .leading),
        GridItem(.fixed(35), alignment: .leading),
        GridItem(.fixed(70), alignment: .leading),
        GridItem(.fixed(70), alignment: .leading),
        GridItem(.fixed(70), alignment: .leading)
    ]
    @State var selectedItem: GeoAddress?
    var header: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: 0
        ) {
            GridCellView(value: "Hop")       // Hop Number
            GridCellView(value: "From")      // Hop Details
            GridCellView(value: "Flag")      // Flag
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
                    pinnedViews: [.sectionHeaders, .sectionFooters]
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
                                }
                            } else {
                                let from = "\(hop[0].from)"
                                let current = viewModel.getGeoAddress(from)
                                // Clickeable grid row
                                GridRow {
                                    if hop.count == 3 {
                                        GridCellView(value: "\(hopIndex)")
                                        GridCellView(value: from)
                                        GridCellView(value: "\(current?.flag ?? "")")
                                        GridCellView(value: hop[0].rtt.millisecsString)
                                        GridCellView(value: hop[1].rtt.millisecsString)
                                        GridCellView(value: hop[2].rtt.millisecsString)
                                    } else if hop.count == 2 {
                                        GridCellView(value: "\(hopIndex)")
                                        GridCellView(value: from)
                                        GridCellView(value: "\(current?.flag ?? "")")
                                        GridCellView(value: hop[0].rtt.millisecsString)
                                        GridCellView(value: hop[1].rtt.millisecsString)
                                        GridCellView(value: "***")
                                    } else if hop.count == 1 {
                                        GridCellView(value: "\(hopIndex)")
                                        GridCellView(value: from)
                                        GridCellView(value: "\(current?.flag ?? "")")
                                        GridCellView(value: hop[0].rtt.millisecsString)
                                        GridCellView(value: "***")
                                        GridCellView(value: "***")
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.selectedItem = current
                                }
                            }
                        }
                    }
                }
            }.sheet(item: $selectedItem) { item in
                TracerouteGeoAddressMapView(address: item)
            }
        }.toolbarBackground(.visible, for: .tabBar)
    }
}
