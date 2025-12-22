//
//  SearchableView.swift
//  NetDiagnostics
//
//  Created by Mac on 22/12/25.
//

import SwiftUI

struct SearchableView: View {
    var caption: String
    @Binding var searchText: String
    var action: (() -> Void)
    @FocusState private var isSearchFocused: Bool // Track focus state
    @State private var active = false
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField(caption, text: $searchText, onEditingChanged: { editing in
                    withAnimation {
                        active = editing
                    }
                })
                .focused($isSearchFocused) // Track focus state
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .onSubmit {
                    action()
                }
            }
            .padding(.horizontal)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            if isSearchFocused {
                Button("Cancel") {
                    searchText = ""
                    withAnimation(.spring()) {
                        isSearchFocused = false
                    }
                }
                .transition(.move(edge: .trailing)) // Add animation for cancel button
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .navigationBarHidden(active)
        // Add animation for navigationBarHidden
        .animation(.spring(response: 1.5, dampingFraction: 2.5, blendDuration: 2.5), value: active)
    }
}
