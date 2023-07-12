//
//  PixelInfoCalculator.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/26/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

struct PixelInfoCalculator {
    
    let state: PPUState
    
    func nextPixelInfo() -> (NESColorIndices, isSpriteZeroBeingHit: Bool) {
        let backgroundIndices = self.backgroundIndices()
        let (foregroundIndices, isForegroundPrioritized, isSpriteZeroBeingRendered) = foregroundInfo()
        let finalIndices = mergedColorIndex(backgroundIndices: backgroundIndices,
                                            foregroundIndices: foregroundIndices,
                                            isForegroundPrioritized: isForegroundPrioritized)
        let isSpriteZeroBeingHit: Bool
        if !backgroundIndices.isSystemBackground && !foregroundIndices.isSystemBackground && isSpriteZeroBeingRendered {
            isSpriteZeroBeingHit = self.isSpriteZeroBeingHit()
        } else {
            isSpriteZeroBeingHit = false
        }
        
        return (finalIndices, isSpriteZeroBeingHit: isSpriteZeroBeingHit)
    }

    private func backgroundIndices() -> NESColorIndices {
        guard state.mask.isRenderingBackground && (state.mask.isRenderingBackgroundLeft || state.cycleCounter >= 9) else {
            return NESColorIndices.systemBackground
        }
        
        let bitMux = UInt16.bit(15) >> state.fineXScroll
        
        let colorLowBit: UInt8 = ((state.backgroundPatternLowShiftRegister & bitMux) != 0) ? 1 : 0
        let colorHighBit: UInt8 = ((state.backgroundPatternHighShiftRegister & bitMux) != 0) ? 1 : 0
        let colorIndex = (colorHighBit << 1) | colorLowBit
        
        let paletteLowBit: UInt8 = ((state.backgroundAttributeLowShiftRegister & bitMux) != 0) ? 1 : 0
        let paletteHighBit: UInt8 = ((state.backgroundAttributeHighShiftRegister & bitMux) != 0) ? 1 : 0
        let paletteIndex = (paletteHighBit << 1) | paletteLowBit
        
        return NESColorIndices(color: colorIndex, palette: paletteIndex)
    }
    
    private func foregroundInfo() -> (indices: NESColorIndices, isForegroundPrioritized: Bool, isSpriteZeroBeingRendered: Bool) {
        
        guard state.mask.isRenderingSprites && (state.mask.isRenderingSpritesLeft || state.cycleCounter >= 9) else {
            return (.systemBackground, false, false)
        }
        
        var indices = NESColorIndices.systemBackground
        var isForegroundPrioritized = false
        var isSpriteZeroBeingRendered = false

        for (i, sprite) in state.spritesShownOnScanline.enumerated() {
            
            guard sprite.x == 0 else { continue }

            let foregroundPixelLowBit: UInt8 = (state.spriteLowShiftRegisters[i].bits(7...7)) != 0 ? 1 : 0  // TODO: Ripe for extraction
            let foregroundPixelHighBit: UInt8 = (state.spriteHighShiftRegisters[i].bits(7...7)) != 0 ? 1 : 0

            indices = .init(color: (foregroundPixelHighBit << 1) | foregroundPixelLowBit,
                            palette: sprite.foregroundPaletteIndex)
            isForegroundPrioritized = sprite.isForegroundPrioritized

            if !indices.isSystemBackground {
                if i == 0 {  // Sprite zero
                    isSpriteZeroBeingRendered = true
                }
                
                // Since the sprite array is in descending-priority order, once we've hit a non-transparent pixel, we're done.
                break
            }
        }
        
        return (indices, isForegroundPrioritized, isSpriteZeroBeingRendered)
    }
        
    private func mergedColorIndex(backgroundIndices background: NESColorIndices,
                                  foregroundIndices foreground: NESColorIndices,
                                  isForegroundPrioritized: Bool) -> NESColorIndices {
        switch (background.isSystemBackground, foreground.isSystemBackground) {
        case (true, true):
            return .systemBackground
        case (true, false):
            return foreground
        case (false, true):
            return background
        case (false, false):
            if isForegroundPrioritized {
                return foreground
            } else {
                return background
            }
        }
    }
                
    private func isSpriteZeroBeingHit() -> Bool {
        guard state.mask.isRenderingBackground && state.mask.isRenderingSprites && state.isSpriteZeroHitPossibleForScanline else {
            return false
        }
        let isLeftmostRenderingEnabled = state.mask.isRenderingBackgroundLeft || state.mask.isRenderingSpritesLeft
        let relevantPixelRange = isLeftmostRenderingEnabled ? (9..<258) : (1..<258)
        return relevantPixelRange.contains(state.cycleCounter)
    }
}
