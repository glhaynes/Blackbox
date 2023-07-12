//
//  TestBus.swift
//  CoreBlackboxTests
//
//  Created by Grady Haynes on 10/7/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import Foundation
@testable import CoreBlackbox

final class TestBus: Bus {
    let cpu: any CPU
    let ppu = PPU2C02(cartridge: nil)  // Just to conform to `Bus`
    let memory: Addressable
    var logger: Logger?
    
    init(cpu: CPU, memory: Addressable, logger: Logger? = nil) {
        self.cpu = cpu
        self.memory = memory
        self.logger = logger
    }
    
    func read(from address: UInt16) -> UInt8 {
        memory.read(from: address)
    }
    
    func write(_ value: UInt8, to address: UInt16) {
        memory.write(value, to: address)
    }
    
    func tick() {
        cpu.tick()
    }
    
    func dmaWriteToPPU(_ value: UInt8, oamMemoryAddress: UInt8) {
        fatalError()
    }
}
