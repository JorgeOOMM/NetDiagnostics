//
//  IPAddr+Ext.swift
//
//  Created by Mac on 18/9/24.
//

import Foundation
import NetDiagnosis

// https://gist.github.com/MatiMax/a2b692c52df4ea7fdb00

func getHostAndAliasesByAddress(ipAddress: String) -> [String] {
    var addr = in_addr()
    inet_pton(AF_INET, ipAddress, &addr)
    return getHostAndAliasesByAddress(addr: addr)
}

func getHostAndAliasesByAddress(addr: in_addr) -> [String] {
    var newaddr: in_addr = addr
    let hostList: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>
    var hostAliases: [String] = []
    let caddr = UInt32(MemoryLayout<in_addr>.size)
    if let hostentPtr = gethostbyaddr(&newaddr, caddr, AF_INET) {
        let newHostent: hostent = hostentPtr.pointee
        let firstCannonicalHostName = String(cString: newHostent.h_name)
        hostAliases.append(firstCannonicalHostName)
        hostList = newHostent.h_aliases
        var index = 0
        while let currentHost = hostList[index] {
            hostAliases.append(String(cString: currentHost))
            index += 1
        }
        return hostAliases
    }
    return []
}

func getHostAndAliasesByAddress64(ipAddress: String) -> [String] {
    var addr = in6_addr()
    inet_pton(AF_INET6, ipAddress, &addr)
    return getHostAndAliasesByAddress64(addr: addr)
}

func getHostAndAliasesByAddress64(addr: in6_addr) -> [String] {
    var newaddr: in6_addr = addr
    let hostList: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>
    var hostAliases: [String] = []
    let caddr = UInt32(MemoryLayout<in6_addr>.size)
    if let hostentPtr = gethostbyaddr(&newaddr, caddr, AF_INET6) {
        let newHostent: hostent = hostentPtr.pointee
        let firstCannonicalHostName = String(cString: newHostent.h_name)
        hostAliases.append(firstCannonicalHostName)
        hostList = newHostent.h_aliases
        var index = 0
        while let currentHost = hostList[index] {
            hostAliases.append(String(cString: currentHost))
            index += 1
        }
        return hostAliases
    }
    return []
}

// MARK: IPAddr
extension IPAddr {
    public var hostName: String? {
        switch self {
        case .ipv4(let addr):
            return getHostAndAliasesByAddress(addr: addr).first
        case .ipv6(let addr):
            return getHostAndAliasesByAddress64(addr: addr).first
        }
    }
}


