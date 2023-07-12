//
//  NESBuilder.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/12/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import Foundation

public enum NESBuilder {
    
    public enum LoggingSubsystem {
        case cpu, ppu, apu, bus, ram, controller
    }
    
    public typealias Loggers = [LoggingSubsystem: Logger]
    
    public static func bus(using kind: CPUKind, cartridge: Cartridge?, isRespectingDecimalMode: Bool = true, loggers: Loggers = [:]) -> NESBus {
        // The NES's 2KiB RAM
        let ram = ProgrammableMemoryInterface(baseAddress: 0, bufferBox: .init(size: 2 * 1024), addressTranslator: { address in
            assert((0x0000...0x1fff).contains(address))
            return address & (2 * 1024 - 1)
        }, logger: loggers[.ram])
        
        let apu = ProgrammableMemoryInterface(baseAddress: 0x4000, bufferBox: .init(size: 0x20), addressTranslator: { address in
            assert((0x4000...0x401f).contains(address))
            //print("APU Access (Unhandled!)")
            return address
        }, logger: loggers[.apu])

        let cpu: CPU
        switch kind {
        case .m6502:
            cpu = M6502(isBCDEnabled: isRespectingDecimalMode, logger: loggers[.cpu])
        case .cpu6502:
            cpu = CPU6502(isRespectingDecimalMode: isRespectingDecimalMode, logger: loggers[.cpu])
        }
        
        let bus = NESBus(cpu: cpu,
                         ppu: PPU2C02(cartridge: cartridge, logger: loggers[.ppu]),
                         apu: apu,
                         ram: ram,
                         cartridge: cartridge,
                         logger: loggers[.bus])

        // Hook the CPU up to the bus
        // TODO: Work out the differences here so we don't have to do this this awkwardly
        (cpu as? M6502)?.bus = bus
        (cpu as? CPU6502)?.bus = bus
        
        return bus
    }
}
