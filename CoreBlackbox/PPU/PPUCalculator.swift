//
//  PPUCalculator.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/27/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

/// A place to put pure functions with no dependencies for use by PPU2C02. Just a convenient way to keep individual files from getting too huge.
enum PPUCalculator {
    
    static func incrementedScrollY(for loopy: LoopyRegister, mask: MaskRegister) -> LoopyRegister {
        guard mask.isRenderingBackground || mask.isRenderingSprites else { return loopy }
            
        var loopy = loopy
        
        if loopy.fineYScroll < 7 {
            loopy.fineYScroll += 1
            // We're still working our way through this tile, so we're done
        } else {
            loopy.fineYScroll = 0
            
            let endOfNametable = 29
            if loopy.coarseYScroll == endOfNametable {
                // We're at the end of the nametable proper (and would be heading into its attribute table if we kept going)
                loopy.coarseYScroll = 0
                loopy.isNametableYBitSet.toggle()
            } else if loopy.coarseYScroll == 31 {
                // TODO: I wouldn't have expected us to ever end up here, but we do in 10-Yard Fight (just after the text animation that plays after opponent skill level is selected) and in Golf (just after startup)
                loopy.coarseYScroll = 0
            } else {
                // Regular increment
                loopy.coarseYScroll += 1
            }
        }
        
        return loopy
    }

    static func transferredAddressX(for loopy: LoopyRegister, temp: LoopyRegister, mask: MaskRegister) -> LoopyRegister {
        guard mask.isRenderingBackground || mask.isRenderingSprites else { return loopy }
        var loopy = loopy
        loopy.isNametableXBitSet = temp.isNametableXBitSet
        loopy.coarseXScroll = temp.coarseXScroll
        return loopy
    }
    
    static func transferredAddressY(for loopy: LoopyRegister, temp: LoopyRegister, mask: MaskRegister) -> LoopyRegister {
        guard mask.isRenderingBackground || mask.isRenderingSprites else { return loopy }
        var loopy = loopy
        loopy.fineYScroll = temp.fineYScroll
        loopy.isNametableYBitSet = temp.isNametableYBitSet
        loopy.coarseYScroll = temp.coarseYScroll
        return loopy
    }
    
    static func incrementedScrollX(for loopy: LoopyRegister, mask: MaskRegister) -> LoopyRegister {
        guard mask.isRenderingBackground || mask.isRenderingSprites else { return loopy }
        
        var loopy = loopy
        
        let isWrappingAround = loopy.coarseXScroll == 31
        if isWrappingAround {
            loopy.coarseXScroll = 0
            loopy.isNametableXBitSet.toggle()
        } else {
            loopy.coarseXScroll += 1
        }
        
        return loopy
    }
    
    static func potentialOAMEntries(oamEntries: [OAMEntry], currentScanlineIndex scanlineIndex: Int, control: ControlRegister) -> [(spriteIndex: Int, OAMEntry)] {
        oamEntries.enumerated().compactMap { spriteIndex, oam in
            let difference = scanlineIndex - Int(oam.y)
            let isScanlineAtSpriteLevel = (0..<control.spriteHeight.rawValue).contains(difference)
            if isScanlineAtSpriteLevel {
                return (spriteIndex, oam)
            } else {
                return nil
            }
        }
    }
}
