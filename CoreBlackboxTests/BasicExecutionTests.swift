//
//  BasicExecutionTests.swift
//  CoreBlackboxTests
//
//  Created by Grady Haynes on 9/3/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import Foundation
import XCTest
@testable import CoreBlackbox

final class BasicExecutionTests: XCTestCase {
    
    func testADCWithCarry() {
        
        // ADC $12
        // ADC $13
        
        let (memory, _) = ROMBuilder.rom(prgROM: "65 12 65 13 4C 04 80".splitBySpaces().uint8Values(),
                                         startingAt: 0x8000,
                                         resetVectorInitialValue: 0x8000,
                                         logger: defaultTestingLogger)
        
        let bus = TestMachineBuilder.buildTestBus(using: cpuKind, memory: memory, logger: defaultTestingLogger)
        
        // Set some values to test with
        var address = UInt16(0x12)
        for value in "ee a0".splitBySpaces().uint8Values() {
            bus.write(value, to: address)
            address += 1
        }
        
        NESExecutor.run(bus, inBatchesOfSystemCycleCount: 1024 * 1024, stoppingAfterBatchIf: { $0.cpu.isInAnInfiniteLoop() })
        
        // 0xee + 0xa0 = 0x18e, so 0x8e and carry set
        XCTAssertEqual(bus.cpu.processorState.a, 0x8e)
        XCTAssertEqual(bus.cpu.processorState.x, 0)
        XCTAssertEqual(bus.cpu.processorState.y, 0)
        XCTAssertTrue(bus.cpu.processorState.p[.carry] != false)
    }
    
    func testExample1FromEasy6502() {

        // LDA #$01
        // STA $0200
        // LDA #$05
        // STA $0201
        // LDA #$08
        // STA $0202

        let (memory, _) = ROMBuilder.rom(prgROM: "a9 01 8d 00 02 a9 05 8d 01 02 a9 08 8d 02 02"/* 4C 0f 80"*/.splitBySpaces().uint8Values(),
                                         startingAt: 0x8000,
                                         resetVectorInitialValue: 0x8000,
                                         logger: defaultTestingLogger)
        let bus = TestMachineBuilder.buildTestBus(using: cpuKind, memory: memory, logger: defaultTestingLogger)
        NESExecutor.run(bus, inBatchesOfSystemCycleCount: 1024 * 1024, stoppingAfterBatchIf: { $0.cpu.isInAnInfiniteLoop() })

        XCTAssertEqual(bus.cpu.processorState.x, 0)
        XCTAssertEqual(bus.cpu.processorState.y, 0)
        //XCTAssertTrue(bus.cpu.processorState.p[.interruptDisable] ?? false)
        XCTAssertEqual(bus.cpu.processorState.a, 0x08)

        // TODO: This is commented out because BRK does some interesting things.
        // See implementation of BRK
        // Confirm that it's what it's supposed to be!
        //XCTAssertEqual(bus.cpu.processorState.pc, 0)

        XCTAssertEqual(bus.read(from: 0x0200), 0x01)
        XCTAssertEqual(bus.read(from: 0x0201), 0x05)
        XCTAssertEqual(bus.read(from: 0x0202), 0x08)
    }

    func testBranching1() {

        //  LDX #$08
        // decrement:
        //  DEX
        //  STX $0200
        //  CPX #$03
        //  BNE decrement
        //  STX $0201
        //  BRK

        //Address  Hexdump   Dissassembly
        //-------------------------------
        //$0600    a2 08     LDX #$08
        //$0602    ca        DEX
        //$0603    8e 00 02  STX $0200
        //$0606    e0 03     CPX #$03
        //$0608    d0 f8     BNE $0602
        //$060a    8e 01 02  STX $0201
        //$060d    00        BRK

        // 0600: a2 08 ca 8e 00 02 e0 03 d0 f8 8e 01 02 00

        // TODO: Fails on .cpu6502 - why, our test of isInAnInfiniteLoop is probably bad...
    
        let (memory, _) = ROMBuilder.rom(
            prgROM: "a2 08 ca 8e 00 02 e0 03 d0 f8 8e 01 02 00".splitBySpaces().uint8Values(),
            startingAt: 0x0600,
            resetVectorInitialValue: 0x0600,
            logger: defaultTestingLogger
        )
        
        let bus = TestMachineBuilder.buildTestBus(using: cpuKind, memory: memory, logger: defaultTestingLogger)
        
        NESExecutor.run(bus,
                        inBatchesOfSystemCycleCount: 1024 * 1024,
                        stoppingAfterBatchIf: { $0.cpu.isInAnInfiniteLoop() })
        
        XCTAssertEqual(bus.cpu.processorState.x, 3)
        // TODO: Could use more asserts here
    }
}

private extension String {
    func splitBySpaces() -> [String] {
        split(separator: " ").map { String($0) }
    }
}

private extension Array where Element == String {
    func uint8Values() -> [UInt8] {
        map { UInt8($0, radix: 16)! }
    }
}
