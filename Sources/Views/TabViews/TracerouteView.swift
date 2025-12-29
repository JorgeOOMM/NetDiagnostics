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

// MARK: TracerouteState
enum TracerouteState {
    case idle
    case running(String)
    case failed(Error)
    
    var isIdle: Bool {
        switch self {
        case .idle:
            return true
        default:
            return false
        }
    }
    
    var isRunning: Bool {
        switch self {
        case .running:
            return true
        default:
            return false
        }
    }
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
    @State private var networkAddress = "www.bing.kr"
    @State private var tracerouteState: TracerouteState = .idle
    
    @ViewBuilder var runButton: some View {
        switch tracerouteState {
        case .failed, .idle:
            Button(action: run) { Label("Run", systemImage: "play.fill") }
                .keyboardShortcut("R")
        case .running:
            ProgressView().progressViewStyle(.circular).padding(.trailing, 6)
        }
    }
    
    init(viewModel: ContentView.ViewModel) {
        self.viewModel = viewModel
    }
    
    func run() {
        tracerouteState = .running(networkAddress)
        
        Task {
            do {
                try await viewModel.traceroute(
                    to: networkAddress,
                    packetSize: Int(config.packetSize),
                    initHop: UInt8(config.initHop),
                    maxHop: UInt8(config.maxHop),
                    packetCount: UInt8(config.packetCount),
                    timeOut: TimeInterval(config.timeOut)
                )
                tracerouteState = .idle
            } catch {
                tracerouteState = .failed(error)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchableView(caption: "Network Address", searchText: $networkAddress) {
                    run()
                }
                TracerouteGridView(viewModel: self.viewModel)
                TracerouteStatusView(status: $tracerouteState)
                .transition(.move(edge: .trailing)) // Add animation for status view
                .animation(
                    .spring(response: 0.5, dampingFraction: 1.5, blendDuration: 1.5),
                    value: tracerouteState.isIdle
                )
            }
            .navigationTitle("Traceroute")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Map", systemImage: "map") {
                        isMapPresented = true
                    }.disabled(tracerouteState.isRunning)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "slider.horizontal.3") {
                        isSettingsPresented = true
                    }.disabled(tracerouteState.isRunning)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    runButton
                }
            }
            .sheet(isPresented: $isMapPresented) {
                NavigationView {
                    VStack {
                        TracerouteMapView(mapRoute: viewModel.mapRoute())
                    }
                    .navigationTitle("Map")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isMapPresented = false
                            }
                        }
                    }
                }
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
        } .frame(maxHeight: .infinity, alignment: .top)
    }
}
