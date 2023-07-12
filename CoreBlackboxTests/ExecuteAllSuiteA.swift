//
//  ExecuteAllSuiteA.swift
//  CoreBlackboxTests
//
//  Created by Grady Haynes on 9/3/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation
import XCTest
@testable import CoreBlackbox

final class ExecuteAllSuiteA: XCTestCase {
    
    func testAllSuiteA() {
        guard let url = Bundle(for: type(of: self)).url(forResource: "AllSuiteA", withExtension: "bin"),
              let data = try? Data(contentsOf: url)
        else {
            XCTFail("Tests are configured incorrectly")
            return
        }

        let (memory, _) = ROMBuilder.rom(prgROM: Array(data),
                                         startingAt: 0x4000,
                                         logger: defaultTestingLogger)
        let bus = TestMachineBuilder.buildTestBus(using: cpuKind, memory: memory, logger: defaultTestingLogger)
                
        NESExecutor.run(bus, inBatchesOfSystemCycleCount: 1024 * 1024, stoppingEarlyIf: { $0.cpu.isInAnInfiniteLoop() })

        // "the value in address $0210 should be $FF, if your CPU passed. You will know that the test is finished when the program counter (PC) has reached address $45C0."

        XCTAssertEqual(bus.read(from: 0x0210), 0xff)
        XCTAssertEqual(bus.cpu.processorState.pc, 0x45c0)
    }
}
