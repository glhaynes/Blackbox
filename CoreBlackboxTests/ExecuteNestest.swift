//
//  ExecuteNestest.swift
//  CoreBlackboxTests
//
//  Created by Grady Haynes on 8/26/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation
import XCTest
@testable import CoreBlackbox

final class ExecuteNestest: XCTestCase {
    func testNestest() {
        guard let romURL = Bundle(for: type(of: self)).url(forResource: "nestest", withExtension: "nes"),
              var data = try? Data(contentsOf: romURL)
        else {
            XCTFail("Tests are configured incorrectly")
            return
        }
        
        // FIXME: ...
        data[0x400c] = 0x00
        data[0x400d] = 0xc0

        guard let iNESFile = try? INESParser.parse(data),
              let cartridge = try? CartridgeBuilder.cartridge(for: iNESFile, url: nil)
        else {
            XCTFail("Tests are configured incorrectly")
            return
        }
        
        let bus = NESBuilder.bus(using: .cpu6502, cartridge: cartridge, isRespectingDecimalMode: false, loggers: NESBuilder.Loggers())
        // FIXME: These should move into the above
        bus.ppu.interruptRaiser = bus
        bus.cartridge?.setInterruptRaiser(bus)
        
        switch cpuKind {
        case .cpu6502:
            for _ in (0..<21) {
                bus.ppu.tick()
            }
            
            // CPU6502 initial values
            (bus.cpu as! CPU6502).processorState.p[.bit5] = true
            (bus.cpu as! CPU6502).processorState.p[.interruptDisable] = true
            print((bus.cpu as! CPU6502).processorState.p)
        case .m6502:
            for _ in 0..<7 {
                bus.cpu.tick()
            }
        }
        
        for _ in 1...100000 { }  // FIXME: Dumb wait cycle for logging
                
        var formatter = NintendulatorStateFormatter(bus: bus)
        
        // Print state before running first instruction
        print(bus.cpu.processorState)
        if let fields = formatter.formattedFields() {
            print("\(formatter.formattedLine(for: fields))")
        }
        formatter.lineCount += 1
        
        var lastPC = bus.cpu.processorState.pc
        
        NESExecutor.run(bus, inBatchesOfSystemCycleCount: 1, stoppingAfterBatchIf: { _ in
            
            // CPU6502 "initial" values
            if bus.cpu is CPU6502 && bus.cpu.processorState.pc == 0xc79e {
                (bus.cpu as! CPU6502).processorState.p[.interruptDisable] = true
                (bus.cpu as! CPU6502).processorState.p[.zero] = true
                //print("OK")
            }

            return [0xc66e/*, 0xc6a2*/].contains(bus.cpu.processorState.pc)
            //return bus.cpu.isInAnInfiniteLoop() //|| $0.cpu.cycleCount > 1024 * 1024 * 1024
        })
        
        // TODO: Would be nice to have some more assertions — this one just tests that the above actually finishes.
        XCTAssertEqual(bus.cpu.processorState.pc, 0xc66e)  // 1024 * 1024 -> 49811 != 50798
        //XCTAssertEqual(bus.cpu.processorState.pc, 0xc6a2)  // 1024 * 1024 -> 49811 != 50798
    }
}
