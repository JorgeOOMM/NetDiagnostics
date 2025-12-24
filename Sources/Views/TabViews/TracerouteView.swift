//
//  TracerouteView.swift
//  NetDiagnostics
//
//  Created by Mac on 3/12/25.
//

import SwiftUI
import IPAddress2City



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
    //private let lookup = GeoAddressLookup()
    
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
            // Get the current IP address for the bogon address cases
            try await viewModel.getCurrentIPAddressIfNeeded()
            
            do {
                try await viewModel.traceroute(
                    to: networkAddress,
                    config: config
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
                .animation(.spring(response: 0.5, dampingFraction: 1.5, blendDuration: 1.5), value: tracerouteState.isIdle)
            }
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
//                let result = self.viewModel.route.compactMap {
//                    if !$0.isEmpty {
//                        return try? AddressElement(address: "\($0[0].from)", lookup: lookup)
//                    }
//                    return nil
//                }
                
                
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
