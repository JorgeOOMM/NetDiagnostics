//
//  GeoAddress.swift
//  NetDiagnostics
//
//  Created by Mac on 13/1/26.
//

import Foundation

// MARK: GeoAddress
public struct GeoAddress: Identifiable, Sendable {
    public let id = UUID()
    // Current Address
    public let address: String
    // Start Range Address
    public let start: String
    // End Range Address
    public let end: String
    // Country for Range Address
    public let country: String
    // Country Flag for Range Address
    public let flag: String
    // Country Subdivision for Range Address
    public let subdivision: String
    // Complete location name
    public var locationName: String {
        subdivision + " - " + country
    }
    // Subdivisions
    public var subdivisions: [String] {
        subdivision.components(separatedBy: " - ")
    }
}
