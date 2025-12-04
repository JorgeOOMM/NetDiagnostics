//
//  PingView.swift
//  NetDiagnostics
//
//  Created by Mac on 3/12/25.
//

import SwiftUI

struct PingView: View {
    
#if os(iOS)
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
#else
    private let isCompact = false
#endif
    
    @State private var viewModel: ContentView.ViewModel
    @State private var networkAddress = "www.google.com"
    
    init(viewModel: ContentView.ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(self.viewModel.pings.format(), id: \.self) { item in
                    Text(item)
                        .scaledFont(name: "Courier", size: 12)
                }
            }.navigationTitle("Ping")
        }
        .searchable(text: $networkAddress, prompt: "Network Address")
        .onSubmit(of: .search) {
            Task {
                try await viewModel.pings(to: networkAddress)
            }
        }
    }
}
