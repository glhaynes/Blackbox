//
//  Mapper000.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 10/6/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

final class Mapper000: Mapper {
    
    public unowned(unsafe) var cartridge: Cartridge!
    public weak var interruptRaiser: (any InterruptRaiser)?
    
    public init() { }
    
    public func scanlineRenderingWasCompletedByPPU() {
        // Do nothing - Mapper 000 doesn't have scanline functionality
    }
    
    public func read(from address: UInt16) -> UInt8? {
        if cartridge.prgROM.count <= 16384 {
            return cartridge.prgROM[Int((address - 0x8000) & 0xbfff)]
        } else {
            return cartridge.prgROM[Int(address - 0x8000)]
        }
    }
    
    public func write(_ value: UInt8, to address: UInt16) -> Bool {
        return false
    }
}
