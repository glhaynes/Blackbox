//
//  BasicTests.swift
//  CoreBlackboxTests
//
//  Created by Grady Haynes on 8/30/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import XCTest
@testable import CoreBlackbox

final class BasicTests: XCTestCase {
    
    func testBCDExtensions() {
        XCTAssertEqual(UInt16(0x00).asBCDValue, 0)
        XCTAssertEqual(UInt16(0x20).asBCDValue, 20)
        XCTAssertEqual(UInt16(0x42).asBCDValue, 42)
        XCTAssertEqual(UInt16(99).bcdAsHexValue, 153)
    }
    
    func testUInt8BitOperations() {
        
        var x: UInt8 = 181  // 10110101
        
        XCTAssertEqual(x[7], true)
        XCTAssertEqual(x[6], false)
        XCTAssertEqual(x[5], true)
        XCTAssertEqual(x[4], true)
        XCTAssertEqual(x[3], false)
        XCTAssertEqual(x[2], true)
        XCTAssertEqual(x[1], false)
        XCTAssertEqual(x[0], true)
        
        x[7] = false
        
        XCTAssertEqual(x, 53)
        XCTAssertEqual(x[7], false)
        XCTAssertEqual(x[6], false)
        XCTAssertEqual(x[5], true)
        XCTAssertEqual(x[4], true)
        XCTAssertEqual(x[3], false)
        XCTAssertEqual(x[2], true)
        XCTAssertEqual(x[1], false)
        XCTAssertEqual(x[0], true)
        
        x[3] = true
        
        XCTAssertEqual(x, 61)
        XCTAssertEqual(x[7], false)
        XCTAssertEqual(x[6], false)
        XCTAssertEqual(x[5], true)
        XCTAssertEqual(x[4], true)
        XCTAssertEqual(x[3], true)
        XCTAssertEqual(x[2], true)
        XCTAssertEqual(x[1], false)
        XCTAssertEqual(x[0], true)
    }
}
