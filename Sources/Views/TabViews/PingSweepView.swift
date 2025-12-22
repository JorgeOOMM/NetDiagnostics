//
//  PingSweepView.swift
//  NetDiagnostics
//
//  Created by Mac on 3/12/25.
//

import SwiftUI

// MARK: PingSweepConfig
struct PingSweepConfig {
    // Ping Sweep configuration
    var packetSize: Float = defaultPacketSize
    var hopLimit: Float = defaultHopLimit
    var timeOut: Float = defaultTimeOut
}
// MARK: PingSweepView
struct PingSweepView: View {
    
#if os(iOS)
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
#else
    private let isCompact = false
#endif
    
    @State var config = PingSweepConfig()
    @State private var discloseSweepPingParams = false
    
    @State private var viewModel: ContentView.ViewModel
    @State private var networkAddress = "113.23.179.1-113.23.179.255"
    
    init(viewModel: ContentView.ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            
            PingGridView(pings: self.viewModel.pingsweeps)
            
            Spacer()
            Group {
                DisclosureGroup(isExpanded: $discloseSweepPingParams) {
                    Spacer()
                    NameTextOverlaySlider(name: "Len",
                                          value: $config.packetSize,
                                          minValue: minPacketSize,
                                          maxValue: maxPacketSize,
                                          step: minPacketSize)
                    Spacer()
                    NameTextOverlaySlider(name:"Time",
                                          value: $config.timeOut,
                                          minValue: minTimeOut,
                                          maxValue: maxTimeOut,
                                          step: 1.0)
                    Spacer()
                    NameTextOverlaySlider(name:"TTL",
                                          value: $config.hopLimit,
                                          minValue: minHopLimit,
                                          maxValue: maxHopLimit,
                                          step: 1.0)
                } label: {
                    HStack {
                        Label("Parameters", systemImage: "slider.horizontal.3")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }.navigationTitle("Ping Sweep")
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(StackNavigationViewStyle())
                .contentMargins(
                              .horizontal,
                              horizontalSizeClass == .regular ? 200 : 50,
                              for: .automatic
                          )
        }
        .searchable(text: $networkAddress, prompt: "Network Address")
        .onSubmit(of: .search) {
            Task {
                let addr = Array(networkAddress.split(separator: "-"))
                if addr.count == 2 {
                    try await viewModel.pingsweep(from: String(addr[0]),
                                                  to: String(addr[1]),
                                                  packetSize: Int(config.packetSize),
                                                  hopLimit: UInt8(config.hopLimit),
                                                  timeOut: TimeInterval(config.timeOut))
                } else {
                    // TODO: show the error
                }
            }
        }
    }
}
