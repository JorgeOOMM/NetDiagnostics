//
//  MapLocation.swift
//  NetDiagnostics
//
//  Created by Mac on 13/1/26.
//

import Foundation
import CoreLocation

// MARK: MapLocation
struct MapLocation: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

extension MapLocation {
    static var unknown = MapLocation(name: "Unknown",
                                     coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
}

// MARK: MapLocation: Hashable
extension MapLocation: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}
extension MapLocation: Equatable {
    static func == (lhs: MapLocation, rhs: MapLocation) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}
