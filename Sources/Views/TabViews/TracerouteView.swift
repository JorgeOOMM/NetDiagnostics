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
    @Environment(\.verticalSizeClass)
    private var verticalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
#else
    private let isCompact = false
#endif
    
    @State private var config = TracerouteConfig()
    
    @State private var isMapPresented = false
    @State private var isSettingsPresented = false
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
        Task {
            await viewModel.traceroute(to: networkAddress,
                                       packetSize: Int(config.packetSize),
                                       initHop: UInt8(config.initHop),
                                       maxHop: UInt8(config.maxHop),
                                       packetCount: UInt8(config.packetCount),
                                       timeOut: TimeInterval(config.timeOut))
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchableView(caption: "Network Address", searchText: $networkAddress) {
                    run()
                }
                
                TracerouteGridView(route: self.viewModel.route)
                    .navigationTitle("Traceroute")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationViewStyle(StackNavigationViewStyle())
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Map", systemImage: "map") {
                                isMapPresented = true
                            }
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Settings", systemImage: "slider.horizontal.3") {
                                isSettingsPresented = true
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            runButton
                        }
                    }
                    .sheet(isPresented: $isMapPresented) {
                        
                    }
                    .sheet(isPresented: $isSettingsPresented) {
                        NavigationView {
                            VStack {
                                TracerouteConfigurationView(config: $config)
                            }
                            .navigationTitle("Settings")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Done") {
                                        isSettingsPresented = false
                                    }
                                }
                            }
                        }
                    }
            }
        } .frame(maxHeight: .infinity, alignment: .top)
    }
}
