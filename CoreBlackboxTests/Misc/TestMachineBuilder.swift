//
//  TestMachineBuilder.swift
//  CoreBlackboxTests
//
//  Created by Grady Haynes on 10/7/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import Foundation
@testable import CoreBlackbox

enum TestMachineBuilder {
    
    public static func buildTestBus(using kind: CPUKind, memory: Addressable, logger: Logger?) -> TestBus {
        switch kind {
        case .m6502:
            let cpu = M6502(isBCDEnabled: true, logger: logger)
            let bus = TestBus(cpu: cpu, memory: memory, logger: logger)
            cpu.bus = bus
            return bus
            
        case .cpu6502:
            let cpu = CPU6502(logger: logger)
            let bus = TestBus(cpu: cpu, memory: memory, logger: logger)
            cpu.bus = bus
            return bus
        }
    }
}
