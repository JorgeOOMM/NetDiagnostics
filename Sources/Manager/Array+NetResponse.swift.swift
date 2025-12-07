//
//  Array+NetResponse.swift
//
//  Created by Mac on 3/12/25.
//

import SwiftUI

//MARK: Traceroute format
extension Array where Element == [NetResponse] {
    func format() -> [String] {
        var result: [String] = []
        for (index, item) in self.enumerated() {
            result.append(format(responses: item, index: index))
        }
        return result
    }
    private func format(responses: Element, index: Int) -> String {
        var sequence: Int = index * 3
        var format: String = "* * *"
        for response in responses {
            if response.sequence == sequence {
                if (sequence % 3) == 0 {
                    if let hostName = response.from.hostName {
                        format = "\(hostName)"
                    } else {
                        format = "\(response.from)"
                    }
                    format += " (\(response.from))"
                }
                format += " \(response.rtt.millisecsString) ms"
            }
            sequence += 1
        }
        return format
    }
}

//MARK: Ping format

extension NetResponse {
    func format() -> String {
        "\(self.len) bytes from \(self.from): icmp_seq=\(self.sequence) ttl=\(self.hopLimit) time=\(self.rtt.millisecsString) ms"
    }
}
extension Array where Element == NetResponse {
    func format() -> [String] {
        var result: [String] = []
        for item in self {
            result.append(item.format())
        }
        return result
    }
}
