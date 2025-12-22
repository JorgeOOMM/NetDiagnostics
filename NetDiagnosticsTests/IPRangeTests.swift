//
//  IPRangeTests.swift
//  NetDiagnostics
//
//  Created by Mac on 7/12/25.
//


import XCTest
@testable import NetDiagnostics

final class IPRangeTests: XCTestCase {
    var range = IPAddressRange()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIPToInt() throws {
        XCTAssert(range.IPToInt(ip: "127.0.0.1") == 2130706433)
        XCTAssert(range.IPToInt(ip: "0.0.1.1") == 257)
        XCTAssert(range.IPToInt(ip: "0.0.0.1") == 1)
    }
    
    func testintToIP() throws {
        XCTAssert(range.intToIP(int: 2130706433) == "127.0.0.1")
        XCTAssert(range.intToIP(int: 257) == "0.0.1.1")
        XCTAssert(range.intToIP(int:  1) == "0.0.0.1")
    }
    
    func testIPRangeIterator() throws {
        let iter = IPRangeIterator(lower: "0.0.1.0", upper: "0.0.2.0")
        XCTAssert(iter.range[0] == "0.0.1.0")
        XCTAssert(iter.range[iter.count - 1] == "0.0.2.0")
    }
}
