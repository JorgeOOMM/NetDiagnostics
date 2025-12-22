//
//  PingView.swift
//  NetDiagnostics
//
//  Created by Mac on 3/12/25.
//

import SwiftUI

// MARK: PingConfig
struct PingConfig {
    // Ping configuration
    var packetSize: Float = defaultPacketSize
    var hopLimit: Float = defaultHopLimit
    var timeOut: Float = defaultTimeOut
    var pingCount: Float = defaultCount
}

// MARK: PingView
struct PingView: View {
    
#if os(iOS)
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
#else
    private let isCompact = false
#endif
    
    @State var config = PingConfig()
    @State private var disclosePingParams = false
    
    @State private var viewModel: ContentView.ViewModel
    @State private var networkAddress = "www.google.com"

    init(viewModel: ContentView.ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            PingGridView(pings: self.viewModel.pings)
            Spacer()
            Group {
                    DisclosureGroup(isExpanded: $disclosePingParams) {
                        Spacer()
                        NameTextOverlaySlider(name:"Len",
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
                        Spacer()
                        NameTextOverlaySlider(name: "Count",
                                    value: $config.pingCount,
                                    minValue: minCount,
                                    maxValue: maxCount,
                                    step: 1.0)
                    } label: {
                        HStack {
                            Label("Parameters", systemImage: "slider.horizontal.3")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }.navigationTitle("Ping")
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
                try await viewModel.pings(to: networkAddress,
                                          packetSize: Int(config.packetSize),
                                          hopLimit: UInt8(config.hopLimit),
                                          timeOut: TimeInterval(config.timeOut),
                                          count: Int(config.pingCount))
            }
        }
    }
}
