//
//  TracerouteStatusView.swift
//  NetDiagnostics
//
//  Created by Mac on 23/12/25.
//


import SwiftUI

struct TracerouteStatusView: View {
    @Binding var status: TracerouteState
    @State private var showErrorPopover = false
    
    func borderStyle() -> some ShapeStyle {
        LinearGradient(
            colors: [.white.opacity(0.5), .gray.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    func errorWithDetails(_ message: String, error: Error) -> any View {
        HStack {
            Button {
                showErrorPopover.toggle()
            } label: {
                Image(systemName: "info.circle")
                    .symbolEffect(.bounce)
            }.buttonStyle(.plain)
                .popover(isPresented: $showErrorPopover) {
                    VStack {
                        if let error = error as? LocalizedError,
                            let description = error.errorDescription {
                            Text(description)
                                .lineLimit(nil)
                                .padding(.all, 5)
                        } else {
                            Text("\(error)")
                                .lineLimit(nil)
                                .padding(.all, 5)
                        }
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
            Text(message)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }.background(Color(.systemBackground))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderStyle(), lineWidth: 1.5))
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
    
    func runingWithDetails(_ message: String) -> any View {
        HStack {
            ProgressView().progressViewStyle(.circular)
            Text(message)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderStyle(), lineWidth: 1.5))
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
    
    var body: some View {
        switch status {
        case .idle:
            EmptyView()
        case .running(let target):
            AnyView(runingWithDetails("Tracerouting \(target)"))
        case .failed(let error):
            AnyView(errorWithDetails("Tracerouting error", error: error))
        }
    }
}

enum ValidationError: LocalizedError {
    case missingAddress
    
    var errorDescription: String? {
        switch self {
        case .missingAddress:
            return "Address not found."
        }
    }
}


#Preview {
 
    @Previewable var error: TracerouteState = .failed(ValidationError.missingAddress)
    @Previewable var status: TracerouteState = .running("www.google.com")
    TracerouteStatusView(status: .constant(status))
    TracerouteStatusView(status: .constant(error))
}
