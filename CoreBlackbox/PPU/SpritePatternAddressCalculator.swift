//
//  SpritePatternAddressCalculator.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/24/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

struct SpritePatternAddressCalculator {
    
    // This type holds some functions related to calculating addresses for sprite patterns.
    // It doesn't have any acccess to mutable state, so it's guaranteed pure.
    
    let scanlineIndex: Int
    let controlRegister: ControlRegister
    
    // TODO: I wonder if we can get rid of the `max(scanlineIndex, 0)`s if we just skip this for scanline == -1s?
    
    func patternAddress(for sprite: OAMEntry) -> (low: UInt16, high: UInt16) {
        let calculateLowAddress = controlRegister.spriteHeight.rawValue == 8 ? calculateLowAddress8x8 : calculateLowAddress8x16
        let spritePatternAddressLow = calculateLowAddress(sprite)
        let spritePatternAddressHigh = spritePatternAddressLow &+ 8
        return (spritePatternAddressLow, spritePatternAddressHigh)
    }
    
    private func calculateLowAddress8x8(for sprite: OAMEntry) -> UInt16 {
        let rowSize: UInt16 = 16
        let cellIndex = UInt16(sprite.tileIndex) * rowSize
        let rowIndex = sprite.isFlippedVertically
                       ? UInt16(7) &- (UInt16(max(scanlineIndex, 0)) &- UInt16(sprite.y))
                       :               UInt16(max(scanlineIndex, 0)) &- UInt16(sprite.y)
        return controlRegister.patternTableAddressFor8x8 | cellIndex | rowIndex
    }
    
    private func calculateLowAddress8x16(for sprite: OAMEntry) -> UInt16 {
        
        // TODO: Note this hasn't been tested at all yet. Find a game that uses 8×16 sprites.
        
        let isTopHalf = scanlineIndex - Int(sprite.y) < 8

        // Note that the pattern table address for 8×16 sprites is determined differently than for 8×8
        let patternTableAddress = UInt16(sprite.tileIndex[0] ? 1 : 0) << 12

        let cellIndex = UInt16(sprite.tileIndex.bits(1...7) + (isTopHalf ? 1 : 0))
        
        let baseRowIndex = UInt16(max(scanlineIndex, 0)) &- UInt16(sprite.y).bits(0...2)
        let rowIndex = sprite.isFlippedVertically
                       ? 7 &- baseRowIndex
                       :      baseRowIndex
        
        return patternTableAddress | cellIndex << 4 | rowIndex
    }
}
