//
//  ViewModel.swift
//
//  Created by Mac on 26/11/25.
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

// MARK: ContentView
extension ContentView {
    @Observable
    class ViewModel {
        private(set) var error: Error?
        private(set) var route: [[NetResponse]] = []
        private(set) var pings: [NetResponse] = []
        private(set) var pingsweeps: [NetResponse] = []
        private(set) var ping: NetResponse = .null
        
        internal var network: NetDiagnosticsProtocol
        
        init(network: NetDiagnosticsProtocol = NetDiagManager()) {
            self.network = network
        }
        
        fileprivate func addPing(_ item: Pinger.Response) {
            let ping = NetResponse(
                len: item.len,
                from: item.from,
                hopLimit: Int(item.hopLimit),
                sequence: Int(item.sequence),
                identifier: Int(item.identifier),
                rtt: item.rtt
            )
            self.ping = ping
        }
        
        fileprivate func addSweepPings(_ items: [Pinger.Response]) {
            var pings: [NetResponse] = []
            for item in items {
                let res = NetResponse(
                    len: item.len,
                    from: item.from,
                    hopLimit: Int(item.hopLimit),
                    sequence: Int(item.sequence),
                    identifier: Int(item.identifier),
                    rtt: item.rtt
                )
                pings.append(res)
            }
            self.pingsweeps = pings
        }
        
        fileprivate func addPings(_ items: [Pinger.Response]) {
            var pings: [NetResponse] = []
            for item in items {
                let res = NetResponse(
                    len: item.len,
                    from: item.from,
                    hopLimit: Int(item.hopLimit),
                    sequence: Int(item.sequence),
                    identifier: Int(item.identifier),
                    rtt: item.rtt
                )
                pings.append(res)
            }
            self.pings = pings
        }
        
        fileprivate func addRoutes(_ items: [[Pinger.Response]] ) {
            var route: [[NetResponse]] = []
            for item in items {
                if item.isEmpty {
                    route.append([])
                } else {
                    route.append(item.map { response in
                        NetResponse(
                            len: response.len,
                            from: response.from,
                            hopLimit: Int(response.hopLimit),
                            sequence: Int(response.sequence),
                            identifier: Int(response.identifier),
                            rtt: response.rtt
                        )
                    })
                }
            }
            self.route = route
        }
    }
}

// MARK: ContentView.ViewModel
extension ContentView.ViewModel {
    // MARK: Ping[s] -> Result<Pinger.Response, Error>
    private func ping(
        hostname: String,
        packetSize: Int? = nil,
        hopLimit: UInt8? = nil,
        timeOut: TimeInterval = 1.0
    ) async throws -> Result<Pinger.Response, Error> {
        precondition(!hostname.isEmpty)
        do {
            // Also support IPv6 address
            // let remoteAddr = IPAddr.create("2620:1ec:c11::200", addressFamily: .ipv6)
            let remoteAddr = try IPAddr.resolve(domainName: hostname)
            if !remoteAddr.isEmpty {
                // Call api request.
                let response = try await network.ping(
                    remoteAddr: remoteAddr[0],
                    packetSize: packetSize,
                    hopLimit: hopLimit,
                    timeOut: timeOut
                )
                return .success(response)
            } else {
                return .failure(NetDiagManager.NetDiagError.unknown)
            }
        } catch {
            return .failure(error)
        }
    }
    
    private func ping(
        address: String,
        packetSize: Int? = nil,
        hopLimit: UInt8? = nil,
        timeOut: TimeInterval = 1.0
    ) async throws -> Result<Pinger.Response, Error> {
        precondition(!address.isEmpty)
        do {
            // Also support IPv6 address
            // let remoteAddr = IPAddr.create("2620:1ec:c11::200", addressFamily: .ipv6)
            if let remoteAddr = IPAddr.create(address, addressFamily: .ipv4) {
                // Call api request.
                let response = try await network.ping(
                    remoteAddr: remoteAddr,
                    packetSize: packetSize,
                    hopLimit: hopLimit,
                    timeOut: timeOut
                )
                return .success(response)
            } else {
                return .failure(NetDiagManager.NetDiagError.unknown)
            }
        } catch {
            return .failure(error)
        }
    }
    
    private func ping(
        pinger: Pinger,
        packetSize: Int? = nil,
        hopLimit: UInt8? = nil,
        timeOut: TimeInterval = 1.0
    ) async throws -> Result<Pinger.Response, Error> {
        do {
            // Call api request.
            let response = try await network.ping(
                pinger: pinger,
                packetSize: packetSize,
                hopLimit: hopLimit,
                timeOut: timeOut
            )
            return .success(response)
            
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: Public functions
    
    func ping(
        _ address: String,
        packetSize: Int? = nil,
        hopLimit: UInt8? = nil,
        timeOut: TimeInterval = 1.0
    ) async {
        do {
            let result = try await ping(
                address: address,
                packetSize: packetSize,
                hopLimit: hopLimit,
                timeOut: timeOut
            )
            switch result {
            case .success(let item):
                self.addPing(item)
            case .failure(let error):
                self.error = error
            }
        } catch {
            self.error = error
        }
    }
    
    func ping(
        to hostname: String,
        packetSize: Int? = nil,
        hopLimit: UInt8? = nil,
        timeOut: TimeInterval = 1.0
    ) async {
        do {
            let result = try await ping(
                hostname: hostname,
                packetSize: packetSize,
                hopLimit: hopLimit,
                timeOut: timeOut
            )
            switch result {
            case .success(let item):
                self.addPing(item)
            case .failure(let error):
                self.error = error
            }
            
        } catch {
            self.error = error
        }
    }
}

// MARK: ContentView.ViewModel
extension ContentView.ViewModel {
    
    // MARK: Traceroute -> Result<[[Pinger.Response]], Error>
    private func traceroute(
        address: String,
        packetSize: Int? = nil,
        initHop: UInt8 = 1,
        maxHop: UInt8 = 64,
        packetCount: UInt8 = 3,
        timeOut: TimeInterval = 1.0
    ) async throws -> Result<[[Pinger.Response]], Error> {
        precondition(!address.isEmpty)
        do {
            // Also support IPv6 address
            // let remoteAddr = IPAddr.create("2620:1ec:c11::200", addressFamily: .ipv6)
            if let remoteAddr = IPAddr.create(address, addressFamily: .ipv4) {
                // Call api request.
                let response = try await network.traceroute(
                    remoteAddr: remoteAddr,
                    packetSize: packetSize,
                    initHop: initHop,
                    maxHop: maxHop,
                    packetCount: packetCount,
                    timeOut: timeOut
                )
                return .success(response)
            } else {
                return .failure(NetDiagManager.NetDiagError.unknown)
            }
        } catch {
            return .failure(error)
        }
    }
    
    private func traceroute(
        hostname: String,
        packetSize: Int? = nil,
        initHop: UInt8 = 1,
        maxHop: UInt8 = 64,
        packetCount: UInt8 = 3,
        timeOut: TimeInterval = 1.0
    ) async throws -> Result<[[Pinger.Response]], Error> {
        precondition(!hostname.isEmpty)
        do {
            // Also support IPv6 address
            // let remoteAddr = IPAddr.create("2620:1ec:c11::200", addressFamily: .ipv6)
            //if let remoteAddr = IPAddr.create(address, addressFamily: .ipv4) {
            let remoteAddr = try IPAddr.resolve(domainName: hostname)
            if !remoteAddr.isEmpty {
                // Call api request.
                let response = try await network.traceroute(
                    remoteAddr: remoteAddr[0],
                    packetSize: packetSize,
                    initHop: initHop,
                    maxHop: maxHop,
                    packetCount: packetCount,
                    timeOut: timeOut
                )
                return .success(response)
            } else {
                return .failure(NetDiagManager.NetDiagError.unknown)
            }
        } catch {
            return .failure(error)
        }
    }
    
    func traceroute(
        _ address: String,
        packetSize: Int? = nil,
        initHop: UInt8 = 1,
        maxHop: UInt8 = 64,
        packetCount: UInt8 = 3,
        timeOut: TimeInterval = 1.0
    ) async throws {
        
        let result = try await traceroute(
            address: address,
            packetSize: packetSize,
            initHop: initHop,
            maxHop: maxHop,
            packetCount: packetCount,
            timeOut: timeOut
        )
        switch result {
        case .success(let items):
            self.addRoutes(items)
        case .failure(let error):
            throw error
        }
    }
    
    func traceroute(
        to hostname: String,
        packetSize: Int? = nil,
        initHop: UInt8 = 1,
        maxHop: UInt8 = 64,
        packetCount: UInt8 = 3,
        timeOut: TimeInterval = 1.0
    ) async throws {

        let result = try await traceroute(
            hostname: hostname,
            packetSize: packetSize,
            initHop: initHop,
            maxHop: maxHop,
            packetCount: packetCount,
            timeOut: timeOut
        )
        switch result {
        case .success(let items):
            self.addRoutes(items)
        case .failure(let error):
            throw error
        }
    }
}

// MARK: ContentView.ViewModel
extension ContentView.ViewModel {
    func pings(
        to hostname: String,
        packetSize: Int? = nil,
        hopLimit: UInt8? = nil,
        timeOut: TimeInterval = 1.0,
        count: Int = 10
    ) async throws {
        if let pinger = try? Pinger(hostName: hostname) {
            let result = try await withThrowingTaskGroup(of: Result<Pinger.Response, Error>.self) { group in
                for _ in (0..<count) {
                    group.addTask {
                        try await self.ping(
                            pinger: pinger,
                            packetSize: packetSize,
                            hopLimit: hopLimit,
                            timeOut: timeOut
                        )
                    }
                }
                return try await group.reduce(into: [Pinger.Response]()) { result, name in
                    switch name {
                    case let .success(item):
                        result.append(item)
                    case let .failure(error):
                        self.error = error
                    }
                }
            }
            self.addPings(result)
        }
    }
}

extension ContentView.ViewModel {
    func pingsweep(
        from source: String,
        to target: String,
        packetSize: Int? = nil,
        hopLimit: UInt8? = nil,
        timeOut: TimeInterval = 1.0
    ) async throws {
        let result = try await withThrowingTaskGroup(of: Result<Pinger.Response, Error>.self) { group in
            for current in IPRangeIterator(lower: source, upper: target) {
                group.addTask {
                    try await self.ping(
                        address: current,
                        packetSize: packetSize,
                        hopLimit: hopLimit,
                        timeOut: timeOut
                    )
                }
            }
            return try await group.reduce(into: [Pinger.Response]()) { result, name in
                switch name {
                case let .success(item):
                    result.append(item)
                case let .failure(error):
                    self.error = error
                }
            }
        }
        self.addSweepPings(result)
    }
}
