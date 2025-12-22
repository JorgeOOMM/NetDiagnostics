//
//  TracerouteConfigurationView.swift
//  NetDiagnostics
//
//  Created by Mac on 22/12/25.
//

import SwiftUI

struct TracerouteConfigurationView: View {
    @Binding var config: TracerouteConfig
    @State private var discloseTracerouteParams = true
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                Group {
                    DisclosureGroup(isExpanded: $discloseTracerouteParams) {
                        Spacer()
                        NameTextOverlaySlider(name: "Len",
                                              value: $config.packetSize,
                                              minValue: minPacketSize,
                                              maxValue: maxPacketSize,
                                              step: 1.0)
                        Spacer()
                        NameTextOverlaySlider(name: "Time",
                                              value: $config.timeOut,
                                              minValue: minTimeOut,
                                              maxValue: maxTimeOut,
                                              step: 1.0)
                        Spacer()
                        NameTextOverlaySlider(name: "InitHop",
                                              value: $config.initHop,
                                              minValue: minInitHop,
                                              maxValue: maxInitHop,
                                              step: 1.0)
                        Spacer()
                        NameTextOverlaySlider(name: "MaxHop",
                                              value: $config.maxHop,
                                              minValue: minMaxHop,
                                              maxValue: maxMaxHop,
                                              step: 1.0)
                        Spacer()
                        NameTextOverlaySlider(name: "PacketCount",
                                              value: $config.packetCount,
                                              minValue: minPacketCount,
                                              maxValue: maxPacketCount,
                                              step: 1.0)
                    } label: {
                        HStack {
                            Label("Parameters", systemImage: "slider.horizontal.3")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}
