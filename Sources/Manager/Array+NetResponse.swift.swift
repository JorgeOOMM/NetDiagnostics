//
//  Array+NetResponse.swift
//
//  Created by Mac on 3/12/25.
//

import SwiftUI

// MARK: Array<[NetResponse]>
extension Array where Element == [NetResponse] {
    func format() -> [String] {
        var result: [String] = []
        for (index, item) in self.enumerated() {
            result.append(formatResponse(responses: item, index: index))
        }
        return result
    }
    private func formatResponse(responses: Element, index: Int) -> String {
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

extension Array where Element == NetResponse {
    func format() -> [String] {
        var result: [String] = []
        for item in self {
            result.append(formatResponse(response: item))
        }
        return result
    }
    private func formatResponse(response: Element) -> String {
        var format = "64 bytes from \(response.from): icmp_seq=\(response.sequence) ttl=\(response.hopLimit) time=\(response.rtt) ms"
        return format
    }
}
