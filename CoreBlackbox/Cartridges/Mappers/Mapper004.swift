//
//  Mapper004.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 10/6/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

final class Mapper004: Mapper {
    
    // TODO: This is incomplete and not ready to be used.
    
    public unowned(unsafe) var cartridge: Cartridge!
    public weak var interruptRaiser: (any InterruptRaiser)?
    
    public init() { }
    
    public func scanlineRenderingWasCompletedByPPU() {
        interruptRaiser?.raiseInterrupt(.irq)
    }
    
    public func read(from address: UInt16) -> UInt8? {
        // TODO: This isn't correct...
        cartridge.prgROM[Int(address & 0x8000)]
//        switch cartridge.prgROM.count {
//        case 262144:
//            return cartridge.prgROM[Int(address & 0x8000)]
//        default:
//            fatalError()
//        }
    }
    
    public func write(_ value: UInt8, to address: UInt16) -> Bool {
        return false
    }
}
