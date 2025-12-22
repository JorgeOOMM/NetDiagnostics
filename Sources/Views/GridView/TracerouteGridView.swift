//
//  TracerouteGridView.swift
//  NetDiagnostics
//
//  Created by Mac on 7/12/25.
//

import IPAddress2City
import SwiftUI

// MARK: TracerouteGridHeaderViewPortrait
struct TracerouteGridHeaderViewPortrait: View {
    var body: some View {
        GridRow {
            GridCellView(value: "From") // Hop Details
            GridCellView(value: "")   // Flag
            GridCellView(value: "RTT1") // Round Trip Time Attempt 1
            GridCellView(value: "RTT2") // Round Trip Time Attempt 2
            GridCellView(value: "RTT3") // Round Trip Time Attempt 3
        }
    }
}
// MARK: TracerouteGridHeaderViewLandscape
struct TracerouteGridHeaderViewLandscape: View {
    var body: some View {
        GridRow {
            GridCellView(value: "Hop")       // Hop Number
            GridCellView(value: "From")      // Hop Details
            GridCellView(value: "Country")   // Country
            GridCellView(value: "")          // Flag
            GridCellView(value: "RTT1")      // Round Trip Time Attempt 1
            GridCellView(value: "RTT2")      // Round Trip Time Attempt 2
            GridCellView(value: "RTT3")      // Round Trip Time Attempt 3
        }
    }
}

// MARK: TracerouteGridView
struct TracerouteGridView: View {
    var route: [[NetResponse]]
    let columnsPortrait = [
        GridItem(.flexible(minimum: 130, maximum: .infinity)),
        GridItem(.flexible(minimum: 30, maximum: 30)),
        GridItem(.flexible(minimum: 65, maximum: 65)),
        GridItem(.flexible(minimum: 65, maximum: 65)),
        GridItem(.flexible(minimum: 65, maximum: 65))
    ]
    let columnsLandscape = [
        GridItem(.flexible(minimum: 35, maximum: 35)),
        GridItem(.flexible(minimum: 220, maximum: .infinity)),
        GridItem(.flexible(minimum: 130, maximum: .infinity)),
        GridItem(.flexible(minimum: 30, maximum: 30)),
        GridItem(.flexible(minimum: 65, maximum: 65)),
        GridItem(.flexible(minimum: 65, maximum: 65)),
        GridItem(.flexible(minimum: 65, maximum: 65))
    ]
    private let lookup = IPAddressGeolocationLookup()
    @State private var orientation = UIDeviceOrientation.unknown
    
    @ViewBuilder
    fileprivate func landscapeGridRowForHop(_ index: Int, _ hop: [NetResponse]) -> some View {
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
            }
        } else {
            let from = "\(hop[0].from)"
            let hostname = hop[0].from.hostName
            let flag = try? lookup.flag(for: from)
            let country = try? lookup.country(for: from)
            
            if hop.count == 3 {
                GridRow {
                    GridCellView(value: "\(hopIndex)")
                    GridCellView(value: hostname ?? from)
                    GridCellView(value: "\(country ?? Countries.localCountry)")
                    GridCellView(value: "\(flag ?? Countries.localFlag)")
                    GridCellView(value: hop[0].rtt.millisecsString)
                    GridCellView(value: hop[1].rtt.millisecsString)
                    GridCellView(value: hop[2].rtt.millisecsString)
                }
            } else if hop.count == 2 {
                GridRow {
                    GridCellView(value: "\(hopIndex)")
                    GridCellView(value: hostname ?? from)
                    GridCellView(value: "\(country ?? Countries.localCountry)")
                    GridCellView(value: "\(flag ?? Countries.localFlag)")
                    GridCellView(value: hop[0].rtt.millisecsString)
                    GridCellView(value: hop[1].rtt.millisecsString)
                    GridCellView(value: "***")
                }
            } else if hop.count == 1 {
                GridRow {
                    GridCellView(value: "\(hopIndex)")
                    GridCellView(value: hostname ?? from)
                    GridCellView(value: "\(country ?? Countries.localCountry)")
                    GridCellView(value: "\(flag ?? Countries.localFlag)")
                    GridCellView(value: hop[0].rtt.millisecsString)
                    GridCellView(value: "***")
                    GridCellView(value: "***")
                }
            }
        }
    }
    
    @ViewBuilder
    fileprivate func portraitGridRowForHop(_ hop: [NetResponse]) -> some View {
        if hop.isEmpty {
            GridRow {
                GridCellView(value: "***")
                GridCellView(value: "***")
                GridCellView(value: "***")
                GridCellView(value: "***")
                GridCellView(value: "***")
            }
        } else {
            let from = "\(hop[0].from)"
            let flag = try? lookup.flag(for: from)
            
            if hop.count == 3 {
                GridRow {
                    GridCellView(value: from)
                    GridCellView(value: flag ?? Countries.localFlag)
                    GridCellView(value: hop[0].rtt.millisecsString)
                    GridCellView(value: hop[1].rtt.millisecsString)
                    GridCellView(value: hop[2].rtt.millisecsString)
                }
            } else if hop.count == 2 {
                GridRow {
                    GridCellView(value: from)
                    GridCellView(value: flag ?? Countries.localFlag)
                    GridCellView(value: hop[0].rtt.millisecsString)
                    GridCellView(value: hop[1].rtt.millisecsString)
                    GridCellView(value: "***")
                }
            } else if hop.count == 1 {
                GridRow {
                    GridCellView(value: from)
                    GridCellView(value: flag ?? Countries.localFlag)
                    GridCellView(value: hop[0].rtt.millisecsString)
                    GridCellView(value: "***")
                    GridCellView(value: "***")
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            
            if orientation == .landscapeLeft ||
                orientation == .landscapeRight ||
                orientation == .faceUp ||
                orientation == .faceDown {
                LazyVGrid(
                    columns: columnsLandscape,
                    alignment: .leading,
                    spacing: 0,
                    pinnedViews: [.sectionHeaders]
                ) {
                    // Add the Grid Header
                    //Section(header: TracerouteGridHeaderViewLandscape()) {
                    TracerouteGridHeaderViewLandscape()
                    ForEach(route.indices, id: \.self) { index in
                        let hop = route[index]
                        landscapeGridRowForHop(index, hop)
                    }
                    //}
                }
            } else {
                LazyVGrid(
                    columns: columnsPortrait,
                    alignment: .leading,
                    spacing: 0,
                    pinnedViews: [.sectionHeaders]
                ) {
                    // Add the Grid Header
                    //Section(header: TracerouteGridHeaderViewPortrait()) {
                    TracerouteGridHeaderViewPortrait()
                    ForEach(route.indices, id: \.self) { index in
                        let hop = route[index]
                        portraitGridRowForHop(hop)
                    }
                    //}
                }
            }
            
        }.onRotate { newOrientation in
            orientation = newOrientation
        }
    }
}
