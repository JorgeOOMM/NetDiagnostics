//
//  CurrentIPAddressGetter.swift
//  NetDiagnostics
//
//  Created by Mac on 24/12/25.
//

import Foundation

// MARK: CurrentIPAddressGetterProtocol
protocol CurrentIPAddressGetterProtocol {
    /// URL for perform the query for the public local IP address
    var getterURL: String {get}
    /// Perform the query for the public local IP address
    ///
    /// - Returns: String?
    ///
    func query() async throws -> String?
    /// Query the public local IP address
    ///
    /// - Returns: String?
    func currentAddress() async throws -> String?
}

// MARK: CurrentIPAddressGetterProtocol
extension CurrentIPAddressGetterProtocol {
    func query() async throws -> String? {
        guard let url = URL(string: getterURL) else {
            return nil
        }
        let request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 60.0)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse {
            if !(200 ..< 300 ~= http.statusCode) {
                print("Error status: \(http.statusCode)")
                return nil
            }
        }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: CurrentIPAddressDYNDNSGetter
struct CurrentIPAddressDYNDNSGetter: CurrentIPAddressGetterProtocol {
    var getterURL: String {
        "http://checkip.dyndns.org"
    }
    func currentAddress() async throws -> String? {
        guard let string = try await query() else {
            return nil
        }
        let result = string
            .components(separatedBy: "Current IP Address: ")[1]
            .components(separatedBy: "<")
        
        return result.first
    }
}
