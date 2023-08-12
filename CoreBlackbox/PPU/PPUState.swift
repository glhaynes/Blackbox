//
//  PPUState.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/24/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public struct PPUState {
    
    var scanlineCounter = 0
    var cycleCounter = 0

    var control = ControlRegister()
    var mask = MaskRegister()
    var status = StatusRegister()
    var loopyTemp = LoopyRegister()
    var loopyMain = LoopyRegister()
    
    var fineXScroll: UInt8 = 0
    
    var externalReadDelayBuffer: UInt8 = 0
    var scrollAndAddressLatch = false
    var nextOAMAccessIndices: (entryIndex: Int, byteIndex: Int) = (0, 0)
    
    var spritesShownOnScanline: [OAMEntry] = []         //.init(repeating: .init(), count: 8)
    var isSpriteZeroHitPossibleForScanline = false

    var nextBackgroundTile: (index: UInt8, attributes: UInt8) = (0, 0)
    var nextBackgroundPattern: UInt16 = 0
    
    var backgroundPatternLowShiftRegister: UInt16 = 0
    var backgroundPatternHighShiftRegister: UInt16 = 0
    var backgroundAttributeLowShiftRegister: UInt16 = 0
    var backgroundAttributeHighShiftRegister: UInt16 = 0
    
    var spriteLowShiftRegisters: [UInt8] = .init(repeating: 0, count: 8)
    var spriteHighShiftRegisters: [UInt8] = .init(repeating: 0, count: 8)
}
