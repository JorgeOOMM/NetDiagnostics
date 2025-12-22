//
//  TracerouteView.swift
//  NetDiagnostics
//
//  Created by Mac on 3/12/25.
//

import SwiftUI

// MARK: TracerouteConfig
struct TracerouteConfig {
    // Traceroute configuration
    var packetSize: Float = defaultPacketSize
    var initHop: Float = minInitHop
    var maxHop: Float = defaultMaxHop
    var packetCount: Float = defaultPacketCount
    var timeOut: Float = defaultTimeOut
}

// MARK: TracerouteView
struct TracerouteView: View {
    
#if os(iOS)
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
#else
    private let isCompact = false
#endif
    
    @State var config = TracerouteConfig()
    @State private var discloseTracerouteParams = false
    @State private var isMapPresented = false
    @State private var viewModel: ContentView.ViewModel
    @State private var networkAddress = "www.google.com"

    init(viewModel: ContentView.ViewModel) {
        self.viewModel = viewModel
    }
    
    @ViewBuilder
    var runButton: some View {
        Button(action: run) { Label("Run", systemImage: "play.fill") }
            .keyboardShortcut("R")
    }
    
    func run() {
        
    }
    var body: some View {
        NavigationStack{
                TracerouteGridView(route: self.viewModel.route)
                      
                Spacer()
                Group {
                    DisclosureGroup(isExpanded: $discloseTracerouteParams) {
                        Spacer()
                        NameTextOverlaySlider(name: "Len",
                                              value: $config.packetSize,
                                              minValue: minPacketSize,
                                              maxValue: maxPacketSize,
                                              step: 1.0)
                        Spacer()
                        NameTextOverlaySlider(name: "Time",
                                              value: $config.timeOut,
                                              minValue: minTimeOut,
                                              maxValue: maxTimeOut,
                                              step: 1.0)
                        Spacer()
                        NameTextOverlaySlider(name: "InitHop",
                                              value: $config.initHop,
                                              minValue: minInitHop,
                                              maxValue: maxInitHop,
                                              step: 1.0)
                        Spacer()
                        NameTextOverlaySlider(name: "MaxHop",
                                              value: $config.maxHop,
                                              minValue: minMaxHop,
                                              maxValue: maxMaxHop,
                                              step: 1.0)
                        Spacer()
                        NameTextOverlaySlider(name: "PacketCount",
                                              value: $config.packetCount,
                                              minValue: minPacketCount,
                                              maxValue: maxPacketCount,
                                              step: 1.0)
                    } label: {
                        HStack {
                            Label("Parameters", systemImage: "slider.horizontal.3")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }.navigationTitle("Traceroute")
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(StackNavigationViewStyle())
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Map", systemImage: "map") {
                            isMapPresented = true
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        runButton
                    }
                }
                .sheet(isPresented: $isMapPresented) {
                    
                }
            }
            .searchable(text: $networkAddress, prompt: "Network Address")
            .onSubmit(of: .search) {
                Task {
                    await viewModel.traceroute(to: networkAddress,
                                               packetSize: Int(config.packetSize),
                                               initHop: UInt8(config.initHop),
                                               maxHop: UInt8(config.maxHop),
                                               packetCount: UInt8(config.packetCount),
                                               timeOut: TimeInterval(config.timeOut))
                }
            }
    }
}
