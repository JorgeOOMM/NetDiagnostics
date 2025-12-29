//
//  TracerouteGeoAddressMapView.swift
//  IPAddress2CityExample
//
//  Created by Mac on 14/12/25.
//  Note: using-mappolyline-overlays-in-mapkit-with-swiftui
//

import MapKit
import SwiftUI

// MARK: TracerouteGeoAddressMapView
struct TracerouteMapView: View {
    /// Route MapLocation
    let mapRoute: [MapLocation]
    /// Current position
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: .newYork,
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        )
    )
    /// Route MapLocation coordinates
    private var mapRouteCoordinates: [CLLocationCoordinate2D] {
        mapRoute.map { $0.coordinate }
    }
    /// Line StrokeStyle
    private let strokeStyle = StrokeStyle(
        lineWidth: 3,
        lineCap: .round,
        lineJoin: .round,
        dash: [5, 5]
    )
    /// Line StrokeStyle Gradient
    private let gradient = Gradient(colors: [.red, .purple, .blue])
    
    var body: some View {
        VStack {
            Map(position: $position, interactionModes: .all) {
                // Add the marks of the route
                ForEach(self.mapRoute) {  mark in
                    Marker(coordinate: mark.coordinate) {
                        Label(mark.name, systemImage: "mappin")
                    }
                }
                // Add the MapPolyline of the route
                MapPolyline(coordinates: self.mapRouteCoordinates)
                .stroke(gradient, style: strokeStyle)
            }
        }.onAppear {
            // Set the local coordinate position
            self.position = MapCameraPosition.region(
                MKCoordinateRegion(
                    center: self.mapRouteCoordinates[0],
                    span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                )
            )
        }
    }
}
