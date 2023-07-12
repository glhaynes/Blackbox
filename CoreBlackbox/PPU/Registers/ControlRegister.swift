//
//  ControlRegister.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/24/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

struct ControlRegister: BitFieldAccessible {
    
    enum SpriteHeight: Int {
        case size8x8 = 8
        case size8x16 = 16
    }
    
    private static let nametableX: (UInt8, UInt8) = bitmaskTuple(startBit: 0)
    private static let nametableY: (UInt8, UInt8) = bitmaskTuple(startBit: 1)
    private static let incrementMode: (UInt8, UInt8) = bitmaskTuple(startBit: 2)
    private static let patternSprite: (UInt8, UInt8) = bitmaskTuple(startBit: 3)
    private static let patternBackground: (UInt8, UInt8) = bitmaskTuple(startBit: 4)
    private static let spriteSize: (UInt8, UInt8) = bitmaskTuple(startBit: 5)
    private static let slaveMode: (UInt8, UInt8) = bitmaskTuple(startBit: 6) // Unused
    private static let enableNMI: (UInt8, UInt8) = bitmaskTuple(startBit: 7)
        
    // TODO: Improve this name
    var isNametableXBitSet: Bool {
        get {
            self[Self.nametableX] != 0
        }
        set {
            self[Self.nametableX] = newValue ? 1 : 0
        }
    }

    // TODO: Improve this name
    var isNametableYBitSet: Bool {
        get {
            self[Self.nametableY] != 0
        }
        set {
            self[Self.nametableY] = newValue ? 1 : 0
        }
    }
    
    // TODO: Improve this name
    var isPatternBackgroundBitSet: Bool {
        get {
            self[Self.patternBackground] != 0
        }
        set {
            self[Self.patternBackground] = newValue ? 1 : 0
        }
    }
    
    var isNMIEnabled: Bool {
        get {
            self[Self.enableNMI] != 0
        }
        set {
            self[Self.enableNMI] = newValue ? 1 : 0
        }
    }
    
    var incrementAmount: UInt16 {
        (self[Self.incrementMode] != 0) ? 32 : 1
    }
    
    var spriteHeight: SpriteHeight {
        self[Self.spriteSize] == 0 ? .size8x8 : .size8x16
    }
    
    var patternTableAddressFor8x8: UInt16 {
        UInt16(self[Self.patternSprite]) << 12
    }
    
    var value: UInt8 = 0
}
