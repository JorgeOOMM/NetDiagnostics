//
//  NetDiagManager.swift
//
//  Created by Mac on 18/9/24.
//

import Foundation
import NetDiagnosis

// MARK: NetDiagStatEventsProtocol
protocol NetDiagStatEventsProtocol {
    func didError(_ error: any Error)
    func didTimeout(_ index: Int, _ hop: UInt8)
    func didPong(_ res: Pinger.Response, _ index: Int, _ hop: UInt8)
    func didHopLimitExceeded(_ res: Pinger.Response, _ index: Int, _ hop: UInt8)
}
// MARK: NetDiagnosticsProtocol
protocol NetDiagnosticsProtocol {
    var events: NetDiagStatEventsProtocol? {get}
    /// ping
    /// - Parameter remoteAddr: IPAddr
    /// - Parameter packetSize: Int?
    /// - Parameter hopLimit: UInt8?
    /// - Parameter timeOut: TimeInterval
    /// - Returns: Pinger.Response
    func ping(
        remoteAddr: IPAddr,
        packetSize: Int?,
        hopLimit: UInt8?,
        timeOut: TimeInterval
    ) async throws -> Pinger.Response
    
    /// ping
    /// - Parameters:
    ///   - pinger: Pinger
    /// - Parameter packetSize: Int?
    /// - Parameter hopLimit: UInt8?
    /// - Parameter timeOut: TimeInterval
    /// - Returns: Pinger.Response
    func ping(
        pinger: Pinger,
        packetSize: Int?,
        hopLimit: UInt8?,
        timeOut: TimeInterval
    ) async throws -> Pinger.Response
    
    /// traceroute
    /// - Parameter remoteAddr: IPAddr
    /// - Parameter packetSize: Int?
    /// - Parameter initHop: UInt8
    /// - Parameter maxHop: UInt8
    /// - Parameter packetCount: UInt8
    /// - Parameter timeOut: TimeInterval
    /// - Returns: [[Pinger.Response]]
    func traceroute(
        remoteAddr: IPAddr,
        packetSize: Int?,
        initHop: UInt8,
        maxHop: UInt8,
        packetCount: UInt8,
        timeOut: TimeInterval
    ) async throws -> [[Pinger.Response]]
}
// MARK: NetDiagManager
class NetDiagManager {
    var events: NetDiagStatEventsProtocol?
    /// init
    /// - Parameter events: NetDiagStatEventsProtocol
    init(events: NetDiagStatEventsProtocol = NetDiagPrintStatEvents()) {
        self.events = events
    }
}
// MARK: NetDiagManager implemenmts NetDiagnosticsProtocol
extension NetDiagManager: NetDiagnosticsProtocol {
    enum NetDiagError: Error {
        case hopLimitExceeded
        case timeout
        case unknown
    }
    /// ping
    /// - Parameter remoteAddr: IPAddr
    /// - Parameter packetSize: Int?
    /// - Parameter hopLimit: UInt8?
    /// - Parameter timeOut: TimeInterval
    /// - Returns: Pinger.Response
    func ping(
        remoteAddr: IPAddr,
        packetSize: Int? = nil,
        hopLimit: UInt8? = nil,
        timeOut: TimeInterval = 1.0
    ) async throws -> Pinger.Response {
        // You must resume the continuation exactly once
        try await withCheckedThrowingContinuation { continuation in
            let pinger = try? Pinger(remoteAddr: remoteAddr)
            pinger?.ping(
                packetSize: packetSize,
                hopLimit: hopLimit,
                timeOut: timeOut
            ) { result in
                switch result {
                case let .pong(data):
                    continuation.resume(returning: data)
                case let .failed(error):
                    continuation.resume(throwing: error)
                case .hopLimitExceeded:
                    continuation.resume(throwing: NetDiagError.hopLimitExceeded)
                case .timeout:
                    continuation.resume(throwing: NetDiagError.timeout)
                }
            }
            if pinger == nil {
                continuation.resume(throwing: NetDiagError.unknown)
            }
        }
    }
    
    /// traceroute
    /// - Parameter remoteAddr: IPAddr
    /// - Parameter packetSize: Int?
    /// - Parameter initHop: UInt8
    /// - Parameter maxHop: UInt8
    /// - Parameter packetCount: UInt8
    /// - Parameter timeOut: TimeInterval
    /// - Returns: [[Pinger.Response]]
    func traceroute(
        remoteAddr: IPAddr,
        packetSize: Int? = nil,
        initHop: UInt8 = 1,
        maxHop: UInt8 = 64,
        packetCount: UInt8 = 3,
        timeOut: TimeInterval = 1.0
    ) async throws -> [[Pinger.Response]] {
        // You must resume the continuation exactly once
        try await withCheckedThrowingContinuation { continuation in
            let tracer = try? Pinger(remoteAddr: remoteAddr)
            tracer?.trace(
                packetSize: packetSize,
                initHop: initHop,
                maxHop: maxHop,
                packetCount: packetCount,
                timeOut: timeOut
            ) { packetResult, stopTrace in
                // TODO: If you want stop trace
                // stopTrace(true)
            } onTraceComplete: { result, status in
                var tracerouted: [[Pinger.Response]] = []
                for (hop, responses) in result {
                    var item = [Pinger.Response]()
                    for (index, response) in responses.enumerated() {
                        switch response {
                        case .hopLimitExceeded(let res):
                            item.append(res)
                            self.events?.didHopLimitExceeded(res, index, hop)
                        case .failed(let error):
                            self.events?.didError(error)
                            continuation.resume(throwing: error)
                        case .timeout:
                            self.events?.didTimeout(index, hop)
                        case .pong(let res):
                            item.append(res)
                            self.events?.didPong(res, index, hop)
                        }
                    }
                    tracerouted.append(item)
                }
                continuation.resume(returning: tracerouted)
            }
            if tracer == nil {
                continuation.resume(throwing: NetDiagError.unknown)
            }
        }
    }
}

extension NetDiagManager {
    /// ping
    /// - Parameter pinger: Pinger
    /// - Parameter packetSize: Int?
    /// - Parameter hopLimit: UInt8?
    /// - Parameter timeOut: TimeInterval
    /// - Returns: Pinger.Response
    func ping(
        pinger: Pinger,
        packetSize: Int? = nil,
        hopLimit: UInt8? = nil,
        timeOut: TimeInterval = 1.0
    ) async throws -> Pinger.Response {
        // You must resume the continuation exactly once
        try await withCheckedThrowingContinuation { continuation in
            pinger.ping(
                packetSize: packetSize,
                hopLimit: hopLimit,
                timeOut: timeOut
            ) { result in
                switch result {
                case let .pong(data):
                    continuation.resume(returning: data)
                case let .failed(error):
                    continuation.resume(throwing: error)
                case .hopLimitExceeded:
                    continuation.resume(throwing: NetDiagManager.NetDiagError.hopLimitExceeded)
                case .timeout:
                    continuation.resume(throwing: NetDiagManager.NetDiagError.timeout)
                }
            }
        }
    }
}
