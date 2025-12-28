//
//  Model.swift
//  NetDiagnostics
//
//  Created by Mac on 23/12/25.
//

import Foundation
import NetDiagnosis

// MARK: NetResponse
public struct NetResponse: Identifiable {
    public var id = UUID()
    public var len: Int
    public var from: IPAddr
    public var hopLimit: Int
    public var sequence: Int
    public var identifier: Int
    public var rtt: TimeInterval
}

extension NetResponse {
    static var null = NetResponse(
        len: 0,
        from: .ipv4(in_addr(s_addr: 0)),
        hopLimit: 0,
        sequence: 0,
        identifier: 0,
        rtt: 0
    )
}


