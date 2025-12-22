//
//  ContentView.swift
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
            PingSweepView(viewModel: viewModel)
                .tabItem {
                    Label("Ping Sweep", systemImage: "network")
                }
        }
    }
}

//struct ContentView: View {
//    var body: some View {
//        
//        Text("Other content")
//            .frame(maxWidth: .infinity, minHeight: 100)
//            .background(Color.yellow)
//        
//        ScrollView(.horizontal) {
//            
//            
//            ScrollView(.vertical) {
//                LazyVGrid(
//                    columns: Array(repeating: GridItem(.fixed(200), spacing: 0, alignment: .center), count: 9),
//                    spacing: 16,
//                    pinnedViews: [.sectionHeaders]
//                ) {
//                    Section(header: header) {
//                        ForEach(1..<500) {
//                            Text("Cell #\($0)")
//                        }
//                    }
//                }
//                
//            }
//        }
//        Text("Other content")
//            .frame(maxWidth: .infinity, minHeight: 100)
//            .background(Color.yellow)
//    }
//
//    var header: some View {
//        LazyVGrid(
//            columns: Array(repeating: GridItem(.fixed(200), spacing: 0, alignment: .center), count: 9),
//            spacing: 16
//        ) {
//            ForEach(1..<10) {
//                Text("Header \($0)")
//            }
//        }
//        .padding(.vertical)
//        .background(Color.blue)
//        .foregroundColor(.white)
//    }
//}

#Preview {
    ContentView()
}
