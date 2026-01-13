//
//  IPAddress2LocationProtocol.swift
//  NetDiagnostics
//
//  Created by Mac on 13/1/26.
//

import Foundation
import IPAddress2Geolocation

// MARK: IPAddress2LocationProtocol
protocol IPAddress2LocationProtocol {
    func locate(with address: String) throws -> GeoAddress
}

// MARK: IPAddress2Location: IPAddress2LocationProtocol
extension IPAddress2Location: IPAddress2LocationProtocol {
    public func locate(with address: String) throws -> GeoAddress {
        GeoAddress(
            address: address,
            start: try start(for: address),
            end: try end(for: address),
            country: try country(for: address),
            flag: try flag(for: address),
            subdivision: try subdivision(for: address)
        )
    }
}
