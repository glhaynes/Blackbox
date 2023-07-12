//
//  StatusRegister.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/24/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

struct StatusRegister: BitFieldAccessible {
    // First 5 bits are unused
    private static let spriteOverflow: (UInt8, UInt8) = bitmaskTuple(startBit: 5)
    private static let spriteZeroHit: (UInt8, UInt8) = bitmaskTuple(startBit: 6)
    private static let verticalBlank: (UInt8, UInt8) = bitmaskTuple(startBit: 7)
    
    var isSpriteOverflowOccurring: Bool {
        get {
            self[Self.spriteOverflow] != 0
        }
        set {
            self[Self.spriteOverflow] = newValue ? 1 : 0
        }
    }
    
    var isSpriteZeroHit: Bool {
        get {
            self[Self.spriteZeroHit] != 0
        }
        set {
            self[Self.spriteZeroHit] = newValue ? 1 : 0
        }
    }
    
    var isInVerticalBlank: Bool {
        get {
            self[Self.verticalBlank] != 0
        }
        set {
            self[Self.verticalBlank] = newValue ? 1 : 0
        }
    }
    
    var value: UInt8 = 0
}
