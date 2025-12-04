//
//  ContentView.swift
//  Proxys
//
//  Created by Mac on 26/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()
    var body: some View {
        
        TabView {
            TracerouteView(viewModel: viewModel)
                .tabItem {
                    Label("Traceroute", systemImage: "list.dash")
                }
            
            PingView(viewModel: viewModel)
                .tabItem {
                    Label("Ping", systemImage: "square.and.pencil")
                }
        }
    }
}

#Preview {
    ContentView()
}
