//
//  Execute6502FunctionalTest.swift
//  CoreBlackboxTests
//
//  Created by Grady Haynes on 8/26/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import Foundation
import XCTest
@testable import CoreBlackbox

final class Execute6502FunctionalTest: XCTestCase {
    
    static let successAddress: UInt16 = 0x3469
    
    // This produces a large amount of logs so we don't use one here during normal operation
    let defaultTestingLogger: Logger? = nil

    func test6502FunctionalTest() throws {
        #if !INCLUDE_LONG_RUNNING_TESTS
        throw XCTSkip()
        #else
        
        guard let url = Bundle(for: type(of: self)).url(forResource: "6502_functional_test", withExtension: "bin"),
              let data = try? Data(contentsOf: url)
        else {
            XCTFail("Tests are configured incorrectly")
            return
        }
        
        let (memory, _) = ROMBuilder.rom(prgROM: Array(data),
                                         startingAt: 0,
                                         resetVectorInitialValue: 0x0400,
                                         logger: defaultTestingLogger)
        
        let bus = TestMachineBuilder.buildTestBus(using: cpuKind, memory: memory, logger: defaultTestingLogger)
        
        NESExecutor.run(bus,
                        inBatchesOfSystemCycleCount: 384_965_481,  // Measured on M6502; maybe we should just set to 0.5 billion or something; CPU6502 says 96_241_371 currently…
                        stoppingAfterBatchIf: { $0.cpu.isInAnInfiniteLoop() })

        XCTAssertEqual(bus.cpu.processorState.pc, Self.successAddress)
        #endif
    }
}
