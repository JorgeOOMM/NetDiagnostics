//
//  NetDiagPrintStatEvents.swift
//
//  Created by Mac on 3/12/25.
//

import Foundation
import NetDiagnosis

struct NetDiagPrintStatEvents: NetDiagStatEventsProtocol {
    func didHopLimitExceeded(_ res: Pinger.Response, _ index: Int, _ hop: UInt8) {
        let msString = "\(res.rtt.millisecsString)"
        if index == 0 {
            let fromAddress = res.from.description
            if let name = res.from.hostName {
                print("\(hop)  \(name) (\(fromAddress)) \(msString) ms ", terminator: "")
            } else {
                print("\(hop)  \(fromAddress) (\(fromAddress)) \(msString) ms ", terminator: "")
            }
        } else if index == 1 {
            print("\(msString) ms ", terminator: "")
        } else if index == 2 {
            print("\(msString) ms ")
        }
    }
    func didPong(_ res: Pinger.Response, _ index: Int, _ hop: UInt8) {
        let msString = "\(res.rtt.millisecsString)"
        if index == 0 {
            let fromAddress = res.from.description
            if let name = res.from.hostName {
                print("\(hop)  \(name) (\(fromAddress)) \(msString) ms ", terminator: "")
            } else {
                print("\(hop)  \(fromAddress) (\(fromAddress)) \(msString) ms ", terminator: "")
            }
        } else if index == 1 {
            print("\(msString) ms ", terminator: "")
        } else if index == 2 {
            print("\(msString) ms ")
        }
    }
    func didTimeout(_ index: Int, _ hop: UInt8) {
        if index == 0 {
            print("\(hop)  * ", terminator: "")
        } else if index == 1 {
            print("* ", terminator: "")
        } else if index == 2 {
            print("* ", terminator: "\n")
        }
    }
    func didError(_ error: any Error) {
        print(error)
    }
}
