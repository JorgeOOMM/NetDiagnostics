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
//
//struct SearchableView: View {
//    var caption: String
//    @Binding var searchText: String
//    var action: (() -> Void)
//    @FocusState private var isSearchFocused: Bool // Track focus state
//    @State private var active = false
//    
//    func borderStyle() -> some ShapeStyle {
//        LinearGradient(
//            colors: [.white.opacity(0.5), .gray.opacity(0.5)],
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
//    }
//    var body: some View {
//        HStack {
//            HStack {
//                Image(systemName: "magnifyingglass").foregroundColor(.gray)
//                TextField(caption, text: $searchText, onEditingChanged: { editing in
//                    withAnimation {
//                        active = editing
//                    }
//                })
//                .focused($isSearchFocused) // Track focus state
//                .padding(.horizontal, 10)
//                .padding(.vertical, 8)
//                .onSubmit {
//                    action()
//                }
//            }
//            .padding(.horizontal)
//            .background(Color(.systemBackground))
//            .cornerRadius(10)
//            .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderStyle(), lineWidth: 1.5))
//            
//            if isSearchFocused {
//                Button("Cancel") {
//                    searchText = ""
//                    withAnimation(.spring()) {
//                        isSearchFocused = false
//                    }
//                }
//                .transition(.move(edge: .trailing)) // Add animation for cancel button
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.horizontal)
//        .navigationBarHidden(active)
//        // Add animation for navigationBarHidden
//        .animation(.spring(response: 0.5, dampingFraction: 1.5, blendDuration: 1.5), value: active)
//    }
//}




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
                TracerouteGridView(route: self.viewModel.route)
                //ZStack(alignment: .bottom) {
                    TracerouteStatusView(status: $tracerouteState)
                    .transition(.move(edge: .trailing)) // Add animation for status view
                    .animation(.spring(response: 0.5, dampingFraction: 1.5, blendDuration: 1.5), value: tracerouteState.isIdle)
                //}
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
