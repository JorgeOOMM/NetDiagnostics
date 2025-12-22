//
//  IPAddr+Ext.swift
//
//  Created by Mac on 18/9/24.
//

import Foundation
import NetDiagnosis

// https://gist.github.com/MatiMax/a2b692c52df4ea7fdb00

// MARK: IPAddr
extension IPAddr {
    
    func getHostAndAliasesByAddress(ipAddress: String) -> [String] {
        var addr = in_addr()
        if inet_pton(AF_INET, ipAddress, &addr) == 1 {
            return getHostAndAliasesByAddress(addr: addr)
        }
        return  []
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
        if inet_pton(AF_INET6, ipAddress, &addr) == 1 {
            return getHostAndAliasesByAddress64(addr: addr)
        }
        return []
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
    
    public var hostName: String? {
        switch self {
        case .ipv4(let addr):
            return getHostAndAliasesByAddress(addr: addr).first
        case .ipv6(let addr):
            return getHostAndAliasesByAddress64(addr: addr).first
        }
    }
}
