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
}

struct TracerouteStatusView: View {
    @Binding var status: TracerouteState
    @State private var showErrorPopover = false
    
    func errorWithDetails(_ message: String, error: Error) -> any View {
        HStack {
            Text(message)
            Spacer()
            Button {
                showErrorPopover.toggle()
            } label: {
                Image(systemName: "info.circle")
            }.buttonStyle(.plain)
            .popover(isPresented: $showErrorPopover) {
                VStack {
                    Text(verbatim: "\(error)")
                    .lineLimit(nil)
                    .padding(.all, 5)
                    Button {
                        showErrorPopover.toggle()
                    } label: {
                        Text("Dismiss").frame(maxWidth: 200)
                    }
                    .padding(.bottom)
                }
                .frame(minWidth: 400, idealWidth: 400, maxWidth: 400)
                .fixedSize()
            }
        }
    }
    
    var body: some View {
        switch status {
        case .idle:
            EmptyView()
        case .running(let target):
            ProgressView("Tracerouting \(target)")
        case .failed(let error):
            AnyView(errorWithDetails("Tracerouting error", error: error))
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
            ProgressView().controlSize(.small).progressViewStyle(.circular).padding(.trailing, 6)
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
                TracerouteStatusView(status: $tracerouteState)
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
