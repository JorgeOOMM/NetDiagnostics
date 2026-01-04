//
//  PlaceInfoView.swift
//  NetDiagnostics
//
//  Created by Mac on 4/1/26.
//

import SwiftUI

struct PlaceInfoView: View {
    let address: GeoAddress
    var body: some View {
        Rectangle()
            .fill(.gray.opacity(0.9))
            .overlay {
                VStack {
                    Spacer()
                    Text(address.address)
                    HStack {
                        Text(address.start)
                        Text(" - ")
                        Text(address.end)
                    }
                    HStack {
                        Text(address.country)
                        Text(address.flag)
                    }
                    Text(address.subdivision)
                    Spacer()
                }
            }
    }
}

#Preview {
    let address = GeoAddress(address: "102.130.125.86", start: "102.130.114.0", end: "102.130.126.255", country: "South Africa", flag: "🇿🇦", subdivision: "Cape Town (Manenberg) - Western Cape")
    PlaceInfoView(address: address)
}
