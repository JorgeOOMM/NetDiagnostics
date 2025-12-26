//
//  ViewModel.swift
//
//  Created by Mac on 26/11/25.
//

import Foundation
import NetDiagnosis
import IPAddress2City

// MARK: GeoAddress
public struct GeoAddress : Identifiable {
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

enum GeoAddressError: Error {
    case localAddressError
}

// MARK: GeoAddressLookupProtocol
protocol GeoAddressLookupProtocol {
    func locate(with address: String) throws -> GeoAddress
}

// MARK: GeoAddressLookup: GeoAddressLookupProtocol
extension GeoAddressLookup: GeoAddressLookupProtocol {
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

// MARK: ContentView
extension ContentView {
    @Observable
    class ViewModel {
        private(set) var error: Error?
        private(set) var route: [[NetResponse]] = []
        private(set) var listOfGeoAddresses: [String: GeoAddress] = [:]
        private(set) var pings: [NetResponse] = []
        private(set) var pingsweeps: [NetResponse] = []
        private(set) var ping: NetResponse = .null
        private(set) var geoAddress: GeoAddress?
        internal let network: NetDiagnosticsProtocol
        internal let localAddressGetter: CurrentIPAddressGetterProtocol
        internal let geolookup: GeoAddressLookupProtocol
    
        
        init(network: NetDiagnosticsProtocol = NetDiagManager(),
             localAddressGetter: CurrentIPAddressGetterProtocol = CurrentIPAddressDYNDNSGetter(),
             geolookup: GeoAddressLookupProtocol = GeoAddressLookup()
        ) {
            
            self.network = network
            self.localAddressGetter = localAddressGetter
            self.geolookup = geolookup
            
            localSetup()
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
            var geoAddress: [String: GeoAddress] = [:]
            for item in items {
                if item.isEmpty {
                    route.append([])
                } else {
                    let currentAddress = "\(item[0].from)"
                    if let current = try? locateGeoAddress(with: currentAddress) {
                        geoAddress[currentAddress] = current
                    }
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
            self.listOfGeoAddresses = geoAddress
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
    ) async throws {
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
                throw error
            }

    }
    
    func ping(
        to hostname: String,
        packetSize: Int? = nil,
        hopLimit: UInt8? = nil,
        timeOut: TimeInterval = 1.0
    ) async throws {
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
            throw error
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
        let range = try IPAddressRangeCollection(lower: source, upper: target)
        let result = try await withThrowingTaskGroup(of: Result<Pinger.Response, Error>.self) { group in
            for current in range {
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


extension ContentView.ViewModel {
    func localSetup() {
        Task {
            do {
                // Get the local IP address for the bogon address cases
                self.geoAddress = try await localGeoAddress()
                
            } catch {
                print(error)
            }
        }
    }
    
    func locateGeoAddress(with address: String) throws -> GeoAddress {
        if try IPAddressUtilities.isBogon(string: address) {
            if let geoAddress = geoAddress {
                return geoAddress
            } else {
                throw GeoAddressError.localAddressError
            }
        }
        return try geolookup.locate(with: address)
    }
    
    /// Get the local GeoAddress
    func localGeoAddress() async throws -> GeoAddress? {
        if let localIPAddress = try await localAddressGetter.currentAddress() {
            return try locateGeoAddress(with: localIPAddress)
        }
        return nil
    }
}
