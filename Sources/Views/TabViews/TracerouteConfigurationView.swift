//
//  TracerouteConfigurationView.swift
//  NetDiagnostics
//
//  Created by Mac on 22/12/25.
//

import SwiftUI

// MARK: TracerouteConfigurationView
struct TracerouteConfigurationView: View {
    @Binding var config: TracerouteConfig
    @State private var discloseTracerouteParams = true
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                Group {
                    DisclosureGroup(isExpanded: $discloseTracerouteParams) {
                        Divider()
                        NameTextOverlaySlider(name: "Len",
                                              value: $config.packetSize,
                                              minValue: minPacketSize,
                                              maxValue: maxPacketSize,
                                              step: 1.0)
                        .padding(.top, 40)
                        NameTextOverlaySlider(name: "Time",
                                              value: $config.timeOut,
                                              minValue: minTimeOut,
                                              maxValue: maxTimeOut,
                                              step: 1.0)
                        NameTextOverlaySlider(name: "Max Hop",
                                              value: $config.maxHop,
                                              minValue: minMaxHop,
                                              maxValue: maxMaxHop,
                                              step: 1.0)
                        NameTextOverlaySlider(name: "Init Hop",
                                              value: $config.initHop,
                                              minValue: minInitHop,
                                              maxValue: maxInitHop,
                                              step: 1.0)
                        NameTextOverlaySlider(name: "Packet Count",
                                              value: $config.packetCount,
                                              minValue: minPacketCount,
                                              maxValue: maxPacketCount,
                                              step: 1.0)
                    } label: {
                        HStack {
                            Label("Parameters", systemImage: "slider.horizontal.3")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }.padding(.horizontal)
    }
}
