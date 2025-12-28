//
//  TracerouteGeoAddressMapView.swift
//  IPAddress2CityExample
//
//  Created by Mac on 14/12/25.
//

import CoreLocation
import MapKit
import SwiftUI
import IPAddress2City


// MARK: TracerouteGeoAddressMapView
struct TracerouteMapView: View {
    let viewModel: ContentView.ViewModel
    @State private var location = MapLocation(name: "New York", coordinate: .newYork)
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: .newYork,
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        )
    )
    var body: some View {
        VStack {
            Map(position: $position, interactionModes: .all) {
                
                ForEach(self.viewModel.mapRoute()) {  mark in
                    Marker(coordinate: mark.coordinate) {
                        Label(mark.name, systemImage: "mappin")
                    }
                }
                
                /// The Map Polyline map content object
                MapPolyline(coordinates: self.viewModel.mapRoute().map{$0.coordinate})
                .stroke(.blue, lineWidth: 5)
            }
        }.onAppear() {
            self.position = MapCameraPosition.region(
                MKCoordinateRegion(
                    center: self.viewModel.mapRoute().first!.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                )
            )

        }
    }
}
