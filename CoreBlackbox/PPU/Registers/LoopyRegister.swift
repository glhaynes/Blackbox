//
//  LoopyRegister.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/24/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

struct LoopyRegister: BitFieldAccessible {
    private static let coarseXScroll: (UInt16, UInt16) = bitmaskTuple(startBit: 0, size: 5)
    private static let coarseYScroll: (UInt16, UInt16) = bitmaskTuple(startBit: 5, size: 5)
    private static let nametableX: (UInt16, UInt16) = bitmaskTuple(startBit: 10)
    private static let nametableY: (UInt16, UInt16) = bitmaskTuple(startBit: 11)
    private static let fineYScroll: (UInt16, UInt16) = bitmaskTuple(startBit: 12, size: 3)
    // (Last bit is unused)
    
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
    
    // TODO: On the below (at least), it's unfortunate how our BitFieldAccessible stuff makes us cast to UInt16 to assign a small value...
    
    var coarseXScroll: UInt8 {
        get {
            UInt8(self[Self.coarseXScroll])
        }
        set {
            self[Self.coarseXScroll] = UInt16(newValue)
        }
    }

    var coarseYScroll: UInt8 {
        get {
            UInt8(self[Self.coarseYScroll])
        }
        set {
            self[Self.coarseYScroll] = UInt16(newValue)
        }
    }

    var fineYScroll: UInt8 {
        get {
            UInt8(self[Self.fineYScroll])
        }
        set {
            self[Self.fineYScroll] = UInt16(newValue)
        }
    }

    var value: UInt16 = 0
}
