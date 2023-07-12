//
//  NESBus.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 8/27/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import Foundation

public final class NESBus: Bus {

    enum AddressRanges {
        static let ram: ClosedRange<UInt16> = 0x0000...0x1fff
        static let ppu: ClosedRange<UInt16> = 0x2000...0x3fff
        static let apu: ClosedRange<UInt16> = 0x4000...0x401f
        static let dmaInitiationAddress: UInt16 = 0x4014
        static let controllerAddresses: [UInt16] = [0x4016, 0x4017]
        static let cartridge: ClosedRange<UInt16> = 0x8000...0xffff
    }
    
    let logger: Logger?
     
    public let cpu: any CPU
    public let ppu: PPU2C02
    public let apu: ProgrammableMemoryInterface
    public let ram: ProgrammableMemoryInterface
    public let cartridge: Cartridge?
    
    public var controllers: [NESController] = []
    public private(set) var cyclesCompleted: UInt64 = 0
    
    public init(cpu: any CPU, ppu: PPU2C02, apu: ProgrammableMemoryInterface, ram: ProgrammableMemoryInterface, cartridge: Cartridge?, logger: Logger? = nil) {
        self.cpu = cpu
        self.ppu = ppu
        self.apu = apu
        self.ram = ram
        self.cartridge = cartridge
        self.logger = logger
    }
    
    private func logInfoPublicly(_ string: String) {
        // TODO: Commented out for speed
        //logger?.info("\(string, privacy: .public)")
    }
}

extension NESBus: Addressable {
        
    public func read(from address: UInt16) -> UInt8 {
        let value = routeRead(to: address)
        logInfoPublicly(CPULog.memoryAccess(.read(from: address, value: value)).string)
        return value
    }
        
    public func write(_ value: UInt8, to address: UInt16) {

        // TODO: 127 isn't right
        logInfoPublicly(CPULog.memoryAccess(.write(to: address, value: value, replacing: 127)).string)
                        
        switch address {
        case AddressRanges.dmaInitiationAddress:
            cpu.setUpDMATransferToPPU(forPage: value)
        case AddressRanges.controllerAddresses[0]:
            controllers[safely: 0]?.latch()
        case AddressRanges.controllerAddresses[1]:
            controllers[safely: 1]?.latch()
        case AddressRanges.apu:
            // TODO: This overlaps with the DMA and controller addresses above!  It's fine because we handle them first, but it seems like a bummer...
            break
        case AddressRanges.ppu:
            ppu.write(value, to: address)
        case AddressRanges.ram:
            ram.write(value, to: address)
        default:
            fatalError()
        }
    }
    
    public func dmaWriteToPPU(_ value: UInt8, oamMemoryAddress: UInt8) {
        ppu.dmaWrite(value, toOAMMemoryAddress: oamMemoryAddress)
    }
        
    public func tick() {
        defer { cyclesCompleted += 1 }

        if cyclesCompleted.isMultiple(of: 3) {
            cpu.tick()
        }
        
        ppu.tick()
    }
    
    private func routeRead(to address: UInt16) -> UInt8 {
        switch address {
        case AddressRanges.controllerAddresses[0]:
            return controllers[safely: 0]?.read() ?? 0
        case AddressRanges.controllerAddresses[1]:
            return controllers[safely: 1]?.read() ?? 0
        case AddressRanges.ppu:
            return ppu.read(from: address)
        case AddressRanges.ram:
            return ram.read(from: address)
        case AddressRanges.cartridge:
            return cartridge?.mapper.read(from: address) ?? 0  // Or maybe `fatalError()`?
        case AddressRanges.apu:
            return 0  // TODO
        default:
            return 0
            // TODO: We used to `fatalError()` here, but that made Ice Climber crash. This seems to fix that. Look into why.
        }
    }
}

extension NESBus: InterruptRaiser {
    public func raiseInterrupt(_ interrupt: Interrupt) {
        cpu.raiseInterrupt(interrupt)
    }
}

// Functions to provide info for presentation
extension NESBus {
    public func readMemory(_ range: ClosedRange<UInt16>) -> [UInt8] {
        range.map { read(from: $0) }
    }

    public var systemStatus: SystemStatus {
        .init(processorState: cpu.processorState, cpuCycleCount: cpu.cycleCount, systemCycleCount: cyclesCompleted)
    }
}

private extension Collection where Index: BinaryInteger {
    subscript(safely index: Index) -> Element? {
        guard count > index else { return nil }
        return self[index]
    }
}
