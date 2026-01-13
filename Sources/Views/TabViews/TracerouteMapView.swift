//
//  TracerouteGeoAddressMapView.swift
//  IPAddress2Geolocation
//
//  Created by Mac on 14/12/25.
//  Note: using-mappolyline-overlays-in-mapkit-with-swiftui
//

import MapKit
import SwiftUI

// TODO: https://ip.guide

// MARK: TracerouteGeoAddressMapView
struct TracerouteMapView: View {
    var viewModel: ContentView.ViewModel
    
    @State private var selectedPlace: MapLocation?
    /// Current position
    ///
    @State private var position: MapCameraPosition = .automatic
    
    /// Route MapLocation
    private var mapRoute: [MapLocation] {
        viewModel.mapRoute().map{ $0.value }
    }
    
    /// Map address from MapLocation id
    ///
    /// - Parameter ident: UUID
    ///
    /// - Returns: String?
    ///
    private func mapAddress(for ident: UUID) -> String? {
        viewModel.mapRoute().first{ $0.value.id == ident }?.key
    }
    
    /// Route MapLocation coordinates
    private var mapRouteCoordinates: [CLLocationCoordinate2D] {
        mapRoute.map { $0.coordinate }
    }
    /// Line StrokeStyle
    private let strokeStyle = StrokeStyle(
        lineWidth: 2,
        lineCap: .round,
        lineJoin: .round,
        dash: [5, 5]
    )
    /// Line StrokeStyle Gradient
    private let gradient = Gradient(colors: [.red, .purple, .blue])
    
    var body: some View {
        VStack {
            Map(position: $position, interactionModes: .all, selection: $selectedPlace) {
                // Add the marks of the route
                ForEach(self.mapRoute) {  place in
                    //                    Annotation(place.name, coordinate: place.coordinate) {
                    //                        AnnotationInfoView(place: place)
                    //                    }
                    //                    .tag(place)
                    //                    .annotationTitles(.hidden)
                    
                    Marker(coordinate: place.coordinate) {
                        Label(place.name, systemImage: "mappin")
                    }.tag(place)
                }
                // Add the MapPolyline of the route
                MapPolyline(coordinates: self.mapRouteCoordinates)
                    .stroke(gradient, style: strokeStyle)
            }.safeAreaInset(edge: .bottom) {
                if let selectedPlace,
                   let selectedMapAddress = self.mapAddress(for: selectedPlace.id),
                   let address = viewModel.getGeoAddress(selectedMapAddress) {
                    PlaceInfoView(address: address)
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding([.top, .horizontal])
                }
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
