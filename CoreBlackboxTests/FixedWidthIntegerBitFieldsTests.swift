//
//  FixedWidthIntegerBitFieldsTests.swift
//  CoreBlackboxTests
//
//  Created by Grady Haynes on 9/10/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation
import XCTest
@testable import CoreBlackbox

final class FixedWidthIntegerBitFieldsTests: XCTestCase {
    
    // TODO: If we're going to apply this to `FixedWidthInteger` rather than `UnsignedInteger`, we should add some test coverage for signed types.
    
    func testUnsignedIntegerBitmasks() {
        XCTAssertEqual(UInt8.bitmask(for: 7...7), 0b10000000) // 128
        XCTAssertEqual(UInt8.bitmask(for: 6...7), 0b11000000) // 192
        XCTAssertEqual(UInt8.bitmask(for: 0...3), 0b00001111) // 15
        XCTAssertEqual(UInt64.bitmask(for: 8...63), (UInt64.max & ~256) + 1)
    }
    
    func testBits() {
        XCTAssertEqual(UInt8(255).bits(2...4), 0b00011100)
        XCTAssertEqual(UInt8(0).bits(2...4), 0)
    }
}
