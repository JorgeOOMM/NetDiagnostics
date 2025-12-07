//
//  Pinger+HostName.swift
//  NetDiagnostics
//
//  Created by Mac on 4/12/25.
//

import NetDiagnosis

extension Pinger {
    convenience init(hostName: String) throws {
        let remoteAddr = try IPAddr.resolve(domainName: hostName)
        try self.init(remoteAddr: remoteAddr[0])
    }
}
