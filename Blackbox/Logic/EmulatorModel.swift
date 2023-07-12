//
//  EmulatorModel.swift
//  Blackbox
//
//  Created by Grady Haynes on 11/8/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreBlackbox

// TODO: Maybe make this an Actor?
final class EmulatorModel {
    
    enum Error: Swift.Error {
        case noCartridge
    }
    
    private static func buildBus(for cartridge: Cartridge?, nesControllers: [NESController], loggers: NESBuilder.Loggers = [:]) -> NESBus {
        let bus = NESBuilder.bus(using: .m6502, cartridge: cartridge, isRespectingDecimalMode: false, loggers: loggers)
        bus.controllers = nesControllers
        bus.ppu.interruptRaiser = bus
        bus.cartridge?.setInterruptRaiser(bus)
        return bus
    }
    
    private let loggers: NESBuilder.Loggers
    private let nesControllers: [NESController]
    private var bus: NESBus

    // MARK: - Values read for display
    
    var screenshot: CGImage? {
        Screenshotter.screenshot(bus: bus)
    }
    
    var cpuState: ProcessorState {
        bus.systemStatus.processorState
    }
    
    var cpuCycleCount: UInt64 {
        bus.systemStatus.cpuCycleCount
    }
    
    var patternTables: (CGImage, CGImage)? {
        Screenshotter.patternTableImages(bus: bus)
    }
    
    var systemPalette: SystemPalette {
        bus.ppu.systemPalette()
    }
    
    private var cartridge: Cartridge? {
        get {
            bus.cartridge
        }
        set {
            bus = Self.buildBus(for: newValue, nesControllers: nesControllers, loggers: loggers)
        }
    }
    
    init(nesControllers: [NESController], loggers: NESBuilder.Loggers = [:]) {
        self.loggers = loggers
        self.nesControllers = nesControllers
        bus = Self.buildBus(for: nil, nesControllers: nesControllers, loggers: loggers)
    }
    
    func loadCartridge(_ cartridge: Cartridge) {
        self.cartridge = cartridge
        reset()
    }
    
    func removeCartridge() {
        self.cartridge = nil
        reset()
    }
    
    func reset() {
        // Might be better to do a real reset of the 6502, the PPU, etc
        bus = Self.buildBus(for: cartridge, nesControllers: nesControllers, loggers: loggers)
    }
    
    func runUntilNewDisplayValuesAvailable() throws {
        guard cartridge != nil else {
            throw Error.noCartridge
        }
        
        // Doing these in batches of 90,000 because that's approximately how many it takes for a new frame.
        NESExecutor.run(bus, inBatchesOfSystemCycleCount: 90_000, stoppingEarlyIf: { bus in
            bus.ppu.hasNewDisplayValues
        })
    }
    
    func displayValuesHaveBeenConsumed() {
        bus.ppu.hasNewDisplayValues = false
    }
}
