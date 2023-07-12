//
//  PPU2C02.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/7/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import Foundation

// TODO: Consider moving more functionality to Control, Mask, Status, and Loopy types
// ----    https://www.nesdev.org/wiki/PPU_registers#Summary

// TODO
// - Do *something* with all the comments referencing purity
// - Revise the MARKs
// - Run through all the TODOs

public final class PPU2C02 {
    
    enum PPULog {
        case clockTick(UInt64)
        case dmaWrite(value: UInt8, oamMemoryAddress: UInt8)
        var string: String {
            ""  // TODO: Fix this
        }
    }
    
    // TODO: Separate these, perhaps via protocols?
    
    // MARK: - External stuff
    
    public var hasNewDisplayValues = false
    public var lastFrame: [RGBValue]?
    public unowned var interruptRaiser: (any InterruptRaiser)!
    
    private var cartridge: Cartridge?
    private var framebuffer: [RGBValue] = .init(repeating: .init(red: 0, green: 0, blue: 0), count: 341 * 262)
    private var framesCompleted = 0

    // TODO: What else of this should get moved to `PPUState`?
    
    private var nametableRAM: [UInt8] = .init(repeating: 0, count: 2 * 1024)
    private var paletteTableRAM: [UInt8] = .init(repeating: 0, count: 32)  // TODO: Consider making this a struct?
    private var oamEntries: [OAMEntry] = .init(repeating: .init(), count: 64)

    private var state = PPUState()
    private var totalCycles: UInt64 = 0
    
    private let logger: Logger?

    // MARK: - Initializer
    
    init(cartridge: Cartridge?, logger: Logger? = nil) {
        self.cartridge = cartridge
        self.logger = logger
    }
    
    // MARK: - Public functions
    
    public func dmaWrite(_ value: UInt8, toOAMMemoryAddress address: UInt8) {
        logInfoPublicly(PPULog.dmaWrite(value: value, oamMemoryAddress: address).string)
        let (entryIndex, byteIndex) = PPURAMAddressTranslator.indicesForOAMAddress(address)
        oamEntries[entryIndex][byteIndex] = value
    }
    
    public func rawPatternTables(palette: UInt8) -> PatternTables {
        .init(one: rawPatternTable(index: 0, palette: palette),
              two: rawPatternTable(index: 1, palette: palette))
    }
    
    // MARK: - Private functions
        
    // MARK: Reads / Writes
    
    private func handleExternalRead(from address: UInt16) -> UInt8 {
        switch address {
        case PPURegisterAddress.control,
             PPURegisterAddress.mask:
            return 0
        case PPURegisterAddress.status:
            // TODO: Seems like we should be resetting the address latch here, according to NESdev
            // TODO: Consider a little more whether we should keep this like this (not using `status.value`)...
            // TODO: Document this
            let retval = (state.status.isInVerticalBlank ? 1 : 0) << 7
                       | (state.status.isSpriteZeroHit ? 1 : 0) << 6
                       | (state.status.isSpriteOverflowOccurring ? 1 : 0) << 5
                       | state.externalReadDelayBuffer.bits(0...4)
            //let retval = state.status.value | state.externalReadDelayBuffer.bits(0...4)
            state.status.isInVerticalBlank = false
            return retval
        case PPURegisterAddress.oamAddress:
            return 0
        case PPURegisterAddress.oamData:
            let (entryIndex, byteIndex) = state.nextOAMAccessIndices
            return oamEntries[entryIndex][byteIndex]
        case PPURegisterAddress.scroll,
             PPURegisterAddress.address:
            return 0
        case PPURegisterAddress.data:
            // We'll return what's in the delay buffer — unless the request is for a palette, which doesn't have a delay
            var retval = state.externalReadDelayBuffer
            
            // Update buffer for next time (or this time if it's a palette)
            state.externalReadDelayBuffer = internalRead(from: UInt16(state.loopyMain.value))

            // If address is that of a palette, that can be returned immediately instead of waiting a cycle
            let isImmediatelyReturnable = state.loopyMain.value >= 0x3f00  // TODO: Use a range instead
            if isImmediatelyReturnable {
                retval = state.externalReadDelayBuffer
            }

            state.loopyMain.value += state.control.incrementAmount
            
            return retval
        default:
            fatalError()  // Impossible to ever end up here
        }
    }
    
    private func handleExternalWrite(_ value: UInt8, to address: UInt16) {
        switch address {
        case PPURegisterAddress.control:
            state.control.value = value
            state.loopyTemp.isNametableXBitSet = state.control.isNametableXBitSet
            state.loopyTemp.isNametableYBitSet = state.control.isNametableYBitSet
        case PPURegisterAddress.mask:
            state.mask.value = value
        case PPURegisterAddress.status:
            break
        case PPURegisterAddress.oamAddress:
            state.nextOAMAccessIndices = PPURAMAddressTranslator.indicesForOAMAddress(value)
        case PPURegisterAddress.oamData:
            let (entryIndex, byteIndex) = state.nextOAMAccessIndices
            oamEntries[entryIndex][byteIndex] = value
        case PPURegisterAddress.scroll:
            let fine = value.bits(0...2)
            let coarse = value >> 3
            
            if !state.scrollAndAddressLatch {
                // First write is treated as X scroll
                state.fineXScroll = fine
                state.loopyTemp.coarseXScroll = coarse
            } else {
                // Second write is treated as Y scroll
                state.loopyTemp.fineYScroll = fine
                state.loopyTemp.coarseYScroll = coarse
            }
            
            state.scrollAndAddressLatch.toggle()
        case PPURegisterAddress.address:
            if !state.scrollAndAddressLatch {
                state.loopyTemp.value.highByte = value
            } else {
                state.loopyTemp.value.lowByte = value
                state.loopyMain.value = state.loopyTemp.value
            }
            state.scrollAndAddressLatch.toggle()
        case PPURegisterAddress.data:
            writeToPPURAM(to: state.loopyMain.value, data: value)
            state.loopyMain.value += state.control.incrementAmount
        default:
            fatalError()
        }
    }
    
    private func internalRead(from address: UInt16) -> UInt8 {
        let address = mirror(address, maxValue: 0x3fff)
        switch address {
        case PPUAddressRanges.cartridge:
            return cartridge?.chrROM[Int(address)] ?? 0
        case PPUAddressRanges.nametables,
             PPUAddressRanges.paletteTables:
            return readFromPPURAM(address)
        default:
            fatalError()
        }
    }

    // MARK: ––––––––––––––––––––––––––––––––––––
    
    private func readFromPPURAM(_ address: UInt16) -> UInt8 {
        switch address {
        case PPUAddressRanges.nametables:
            guard let mirroring = cartridge?.mirroring else { return 0 }
            let (nametableIndex, offset) = PPURAMAddressTranslator.nametableLocation(forAddress: address, cartMirror: mirroring)
            let index = PPURAMAddressTranslator.nametableRAMIndex(forNametableIndex: nametableIndex, offset: offset)
            return nametableRAM[index]
        case PPUAddressRanges.paletteTables:
            let index = PPURAMAddressTranslator.paletteTableIndex(forAddress: address)
            return paletteTableRAM[index] & (state.mask.isGrayscale ? 0x30 : 0x3f)  // TODO: Maybe move some of this to `MaskRegister`
        default:
            fatalError()  // Should never end up here, I wouldn't think
        }
    }

    private func writeToPPURAM(to address: UInt16, data: UInt8) {
        assert(address < 0x4000)
        
        switch address {
        case PPUAddressRanges.cartridge:
            fatalError()
        case PPUAddressRanges.nametables:
            guard let mirroring = cartridge?.mirroring else { return }
            let (nametableIndex, offset) = PPURAMAddressTranslator.nametableLocation(forAddress: address, cartMirror: mirroring)
            let index = PPURAMAddressTranslator.nametableRAMIndex(forNametableIndex: nametableIndex, offset: offset)
            nametableRAM[index] = data
        case PPUAddressRanges.paletteTables:
            let index = PPURAMAddressTranslator.paletteTableIndex(forAddress: address)
            paletteTableRAM[index] = data
        default:
            fatalError()  // Should never end up here, I wouldn't think
        }
    }
        
    private func performStateUpdateForVisibleScanline() {
        
        // TODO: This is like 90% of our state machine... where else do we behave based on scanlineCounter or cycleCounter?
        // TODO: Can we use more ranges here?
        
        let isOddFrame = framesCompleted % 2 == 1
        if state.scanlineCounter == 0 && state.cycleCounter == 0 && isOddFrame && (state.mask.isRenderingBackground || state.mask.isRenderingSprites) {
            state.cycleCounter += 1  // "Odd Frame" cycle skip
        }
                
        if state.scanlineCounter == -1 && state.cycleCounter == 1 {
            prepareForNextScanline()
        }
        
        if (2..<258).contains(state.cycleCounter) || (321..<338).contains(state.cycleCounter) {
            updateBackgroundShiftRegisters()
            updateSpriteShiftRegisters()
            progressStateForCycle()
        }
        
        if state.cycleCounter == 256 {
            // End of a visible scanline, so increment downwards...
            state.loopyMain = PPUCalculator.incrementedScrollY(for: state.loopyMain, mask: state.mask)
        }
        
        if state.cycleCounter == 257 {
            //...and reset the x position
            populateBackgroundShiftRegisters()
            state.loopyMain = PPUCalculator.transferredAddressX(for: state.loopyMain, temp: state.loopyTemp, mask: state.mask)
        }
        
        if state.cycleCounter == 338 || state.cycleCounter == 340 {
            // Superfluous read:
            state.nextBackgroundTile.index = internalRead(from: PPUAddressRanges.nametables.lowerBound + state.loopyMain.value.bits(0...11))
        }
        
        if state.scanlineCounter == -1 && (280..<305).contains(state.cycleCounter) {
            // End of vertical blank period so reset the Y address ready for rendering
            state.loopyMain = PPUCalculator.transferredAddressY(for: state.loopyMain, temp: state.loopyTemp, mask: state.mask)
        }

        if state.cycleCounter == 257 && state.scanlineCounter >= 0 {
            handleEndOfVisibleScanline()
        }

        if state.cycleCounter == 340 {
            let spriteShiftRegisters = calculateSpriteShiftRegisters()
            state.spriteLowShiftRegisters = spriteShiftRegisters.low
            state.spriteHighShiftRegisters = spriteShiftRegisters.high
        }
    }
    
    // MARK: - Background calculations
    
    private func progressStateForCycle() {
        switch (state.cycleCounter - 1) % 8 {
        case 0:
            populateBackgroundShiftRegisters()
            state.nextBackgroundTile.index = internalRead(from: PPUAddressRanges.nametables.lowerBound + state.loopyMain.value.bits(0...11))
        case 1:
            break
        case 2:
            state.nextBackgroundTile.attributes = nextBackgroundTileAttributes(loopy: state.loopyMain)
        case 3:
            break
        case 4:
            let byte = byteOfBackgroundPattern(isHighByte: false,
                                               isPatternBackgroundBitSet: state.control.isPatternBackgroundBitSet,
                                               bgNextTileIndex: state.nextBackgroundTile.index,
                                               fineYScroll: state.loopyMain.fineYScroll)
            state.nextBackgroundPattern.lowByte = byte
        case 5:
            break
        case 6:
            let byte = byteOfBackgroundPattern(isHighByte: true,
                                               isPatternBackgroundBitSet: state.control.isPatternBackgroundBitSet,
                                               bgNextTileIndex: state.nextBackgroundTile.index,
                                               fineYScroll: state.loopyMain.fineYScroll)
            state.nextBackgroundPattern.highByte = byte
        case 7:
            state.loopyMain = PPUCalculator.incrementedScrollX(for: state.loopyMain, mask: state.mask)
        default:
            fatalError()  // Impossible
        }
    }
    
    // TODO: Consider whether to use this a few more places - or drop it entirely. Maybe add it to the UInt16 extensions or make it a private top-level? [note it also is duplicated in PPURAMAddressTranslator]
    private func mirror<T: UnsignedInteger>(_ address: T, maxValue: T) -> T {
        address & maxValue
    }
    
    private func logInfoPublicly(_ string: String) {
        // TODO: Commented out for speed
        //logger?.info("\(string, privacy: .public)")
    }
}

// MARK: - Various functions that are [I think] impure only because of `internalRead`

extension PPU2C02 {
    public func systemPalette() -> SystemPalette {
        let backgroundBase: UInt16 = 0x3f00
        let backgroundColorIndex = NESColorIndex(internalRead(from: backgroundBase))
        return SystemPalette(background: backgroundColorIndex, palettes: palettes())
    }
    
    // Unused
    //public func nametables() -> [[UInt8]] {
    //    PPUAddressRanges.individualNametables.map { $0.map { internalRead(from: $0) } }
    //}
    
    private func palettes() -> NESPalettes {
        let base: UInt16 = 0x3f00
        let colorSlotsPerPalette: UInt16 = 4
        return (
            (
                NESColorIndex(internalRead(from: base + 0 * colorSlotsPerPalette + 1)),
                NESColorIndex(internalRead(from: base + 0 * colorSlotsPerPalette + 2)),
                NESColorIndex(internalRead(from: base + 0 * colorSlotsPerPalette + 3))
            ),
            (
                NESColorIndex(internalRead(from: base + 1 * colorSlotsPerPalette + 1)),
                NESColorIndex(internalRead(from: base + 1 * colorSlotsPerPalette + 2)),
                NESColorIndex(internalRead(from: base + 1 * colorSlotsPerPalette + 3))
            ),
            (
                NESColorIndex(internalRead(from: base + 2 * colorSlotsPerPalette + 1)),
                NESColorIndex(internalRead(from: base + 2 * colorSlotsPerPalette + 2)),
                NESColorIndex(internalRead(from: base + 2 * colorSlotsPerPalette + 3))
            ),
            (
                NESColorIndex(internalRead(from: base + 3 * colorSlotsPerPalette + 1)),
                NESColorIndex(internalRead(from: base + 3 * colorSlotsPerPalette + 2)),
                NESColorIndex(internalRead(from: base + 3 * colorSlotsPerPalette + 3))
            ),
            (
                NESColorIndex(internalRead(from: base + 4 * colorSlotsPerPalette + 1)),
                NESColorIndex(internalRead(from: base + 4 * colorSlotsPerPalette + 2)),
                NESColorIndex(internalRead(from: base + 4 * colorSlotsPerPalette + 3))
            ),
            (
                NESColorIndex(internalRead(from: base + 5 * colorSlotsPerPalette + 1)),
                NESColorIndex(internalRead(from: base + 5 * colorSlotsPerPalette + 2)),
                NESColorIndex(internalRead(from: base + 5 * colorSlotsPerPalette + 3))
            ),
            (
                NESColorIndex(internalRead(from: base + 6 * colorSlotsPerPalette + 1)),
                NESColorIndex(internalRead(from: base + 6 * colorSlotsPerPalette + 2)),
                NESColorIndex(internalRead(from: base + 6 * colorSlotsPerPalette + 3))
            ),
            (
                NESColorIndex(internalRead(from: base + 7 * colorSlotsPerPalette + 1)),
                NESColorIndex(internalRead(from: base + 7 * colorSlotsPerPalette + 2)),
                NESColorIndex(internalRead(from: base + 7 * colorSlotsPerPalette + 3))
            )
        )
    }

    private func calculateSpriteShiftRegisters() -> (low: [UInt8], high: [UInt8]) {
        let calculator = SpritePatternAddressCalculator(scanlineIndex: state.scanlineCounter, controlRegister: state.control)
                                                        
        var lowShiftRegisters: [UInt8] = []
        var highShiftRegisters: [UInt8] = []
        
        for sprite in state.spritesShownOnScanline {
            let (patternAddressLow, patternAddressHigh) = calculator.patternAddress(for: sprite)

            // TODO: We could just read directly from chrROM here. Then, this would be a pure function and could also be moved into SpritePatternAddressCalculator (to become SpriteShiftRegisterCalculator).
            // But I'm putting that off until we've learned more about mappers — might not be appropriate.
            // Or perhaps we should just share a reference to `internalRead(from:)` with that type... though then we'd lose our guarantee of its purity.
            // Maybe we could separate out the CHR access into its own (pure) function and share _that_ out... again, depends on how mappers work.
            
            var low = internalRead(from: patternAddressLow)
            var high = internalRead(from: patternAddressHigh)
            if sprite.isFlippedHorizontally {
                low = low.reversed()
                high = high.reversed()
            }
            
            lowShiftRegisters.append(low)
            highShiftRegisters.append(high)
        }
        
        // TODO: Why is this necessary (else we crash in SMB on 2nd attract loop)? Work out how this and `spritesOnScanline` relate
        while lowShiftRegisters.count != 8 {
            lowShiftRegisters.append(0)
        }
        while highShiftRegisters.count != 8 {
            highShiftRegisters.append(0)
        }

        return (lowShiftRegisters, highShiftRegisters)
    }
    
    private func nextBackgroundTileAttributes(loopy: LoopyRegister) -> UInt8 {
        var attributes = internalRead(from: 0x23c0  // TODO: This is the lower bound of the first nametable's attribute table, right?
                                      | UInt16(loopy.isNametableYBitSet ? 1 : 0) << 11
                                      | UInt16(loopy.isNametableXBitSet ? 1 : 0) << 10
                                      | (UInt16(loopy.coarseYScroll) >> 2) << 3
                                      | UInt16(loopy.coarseXScroll) >> 2)
        
        if loopy.coarseXScroll[1] {  // TODO: Prime for extraction
            attributes >>= 2
        }

        if loopy.coarseYScroll[1] {  // TODO: Prime for extraction
            attributes >>= 4
        }
        
        return mirror(attributes, maxValue: 3)  // TODO: Is this how we want to use `mirror`?
    }
    
    private func byteOfBackgroundPattern(isHighByte: Bool, isPatternBackgroundBitSet: Bool, bgNextTileIndex: UInt8, fineYScroll: UInt8) -> UInt8 {
        internalRead(from: (UInt16(isPatternBackgroundBitSet ? 1 : 0) << 12)
                         + (UInt16(bgNextTileIndex) << 4)
                         + (UInt16(fineYScroll))
                         + (UInt16(isHighByte ? 8 : 0)))
    }
    
    private func rgbValueFromPaletteRAM(for indices: NESColorIndices) -> RGBValue {
        // TODO: Which way should we do this?  Hash through the options and their implications...
//        let colorIndex = paletteTableRAM[Int(palette << 2) + Int(pixel)]
        let colorIndex = internalRead(from: PPUAddressRanges.paletteTables.lowerBound
                                            + (UInt16(indices.palette) << 2)
                                            + UInt16(indices.color))
        return NESRenderPalette[NESColorIndex(colorIndex)]
    }
        
    private func rawPatternTable(index: Int, palette: UInt8) -> Sprite {
        
        var sprite = Sprite(width: 128, height: 128)  // 16×16 8×8 tiles
        
        for nTileY in 0..<16 {
            for nTileX in 0..<16 {
                for row in 0..<8 {
                    let nOffset = nTileY * 256 + nTileX * 16  // Convert the 2D tile coordinate into a 1D offset into the pattern table memory
                    let lsbAddress = UInt16(index * 0x1000 + nOffset + row)
                    var tileLSB = internalRead(from: lsbAddress)
                    var tileMSB = internalRead(from: lsbAddress + 8)
                    
                    for column in 0..<8 {
                        let color = (tileMSB[1] ? 1 : 0) << 1 | (tileLSB[1] ? 1 : 0) as UInt8
                        
                        tileLSB >>= 1
                        tileMSB >>= 1
                        
                        let x = nTileX * 8 + (7 - column)
                        let y = nTileY * 8 + row
                        
                        let displayPixel = rgbValueFromPaletteRAM(for: .init(color: color, palette: palette))
                        
                        sprite.setPixel(x: x, y: y, value: displayPixel )
                    }
                }
            }
        }
                
        return sprite
    }
}

// MARK: - Various functions that are impure but could be made pure

extension PPU2C02 {

    private func populateBackgroundShiftRegisters() {
        
        // Top 8 bits: (part of) the current 8 pixels being drawn
        // Bottom 8 bits: (part of) the next 8 pixels to be drawn
        
        state.backgroundPatternLowShiftRegister |= UInt16(state.nextBackgroundPattern.lowByte)
        state.backgroundPatternHighShiftRegister |= UInt16(state.nextBackgroundPattern.highByte)
        
        state.backgroundAttributeLowShiftRegister |= state.nextBackgroundTile.attributes[0] ? 0xff : 0x00
        state.backgroundAttributeHighShiftRegister |= state.nextBackgroundTile.attributes[1] ? 0xff : 0x00
    }
    
    private func updateBackgroundShiftRegisters() {
        guard state.mask.isRenderingBackground else { return }
        state.backgroundPatternLowShiftRegister <<= 1
        state.backgroundPatternHighShiftRegister <<= 1
        state.backgroundAttributeLowShiftRegister <<= 1
        state.backgroundAttributeHighShiftRegister <<= 1
    }
    
    private func updateSpriteShiftRegisters() {
        // TODO: Consider naming this range
        guard state.mask.isRenderingSprites && (1...257).contains(state.cycleCounter) else { return }
        for i in 0..<state.spritesShownOnScanline.count {
            if state.spritesShownOnScanline[i].x > 0 {
                state.spritesShownOnScanline[i].x -= 1
            } else {
                state.spriteLowShiftRegisters[i] <<= 1
                state.spriteHighShiftRegisters[i] <<= 1
            }
        }
    }
}

// MARK: - Various functions that are impure

extension PPU2C02 {
    
    // MARK: Set up for next scanline
    
    private func prepareForNextScanline() {
        state.status.isInVerticalBlank = false
        state.status.isSpriteOverflowOccurring = false
        state.status.isSpriteZeroHit = false
        state.spriteLowShiftRegisters = .init(repeating: 0, count: 8)
        state.spriteHighShiftRegisters = .init(repeating: 0, count: 8)
    }

    private func handleEndOfVisibleScanline() {
        clearScanlineSpriteInfo()
        clearSpriteShiftRegisters()
        populateSpritesForScanline()
    }

    private func clearScanlineSpriteInfo() {
        // TODO: OneLoneCoder cleared these to all 0xffs; do we need to?
        state.spritesShownOnScanline = state.spritesShownOnScanline.map { _ in .init() }
        state.isSpriteZeroHitPossibleForScanline = false
    }
    
    private func clearSpriteShiftRegisters() {
        state.spriteLowShiftRegisters = state.spriteLowShiftRegisters.map { _ in 0 }
        state.spriteHighShiftRegisters = state.spriteHighShiftRegisters.map { _ in 0 }
    }
    
    private func populateSpritesForScanline() {
        let potentialOAMEntries = PPUCalculator.potentialOAMEntries(oamEntries: oamEntries, currentScanlineIndex: state.scanlineCounter, control: state.control)
        state.isSpriteZeroHitPossibleForScanline = potentialOAMEntries.contains { $0.0 == 0 }
        state.status.isSpriteOverflowOccurring = potentialOAMEntries.count > 8
        state.spritesShownOnScanline = potentialOAMEntries.isEmpty
                                     ? []
                                     : Array(potentialOAMEntries.map { $0.1 }[0..<min(8, potentialOAMEntries.count)])
    }
}

// MARK: - `Addressable` conformance

extension PPU2C02: Addressable {
    
    public func read(from address: UInt16) -> UInt8 {
        handleExternalRead(from: mirrorIncomingAddress(address))
        // TODO: Logging
    }
    
    public func write(_ value: UInt8, to address: UInt16) {
        handleExternalWrite(value, to: mirrorIncomingAddress(address))
        // TODO: Logging
    }
        
    public func tick() {
        
        logInfoPublicly(PPULog.clockTick(totalCycles).string)
        
        advanceState(forScanlineIndex: state.scanlineCounter, cycleIndex: state.cycleCounter)
        
        if state.scanlineCounter != -1 {
            let pixelInfo = PixelInfoCalculator(state: state).nextPixelInfo()
            
            populateFrameBuffer(for: pixelInfo)
            
            if pixelInfo.isSpriteZeroBeingHit {
                state.status.isSpriteZeroHit = true
            }
        }
        
        if state.cycleCounter == 340 {
            state.cycleCounter = 0
            handleLastCycleForScanline()
        } else {
            state.cycleCounter += 1
            
            if (state.mask.isRenderingBackground || state.mask.isRenderingSprites) && state.cycleCounter == 260 && state.scanlineCounter < 240 {
                cartridge?.mapper.scanlineRenderingWasCompletedByPPU()
            }
        }
        
        totalCycles += 1
    }
            
    private func advanceState(forScanlineIndex scanlineIndex: Int, cycleIndex: Int) {
        let prerenderLine = -1
        let visibleScanlines = 0...239
        let postrenderLine = 240
        let raiseVerticalBlankAndNMILine = 241
        let verticalBlankLines = 242...260
        
        switch scanlineIndex {
        case prerenderLine, visibleScanlines:
            performStateUpdateForVisibleScanline()
        case postrenderLine:
            break
        case raiseVerticalBlankAndNMILine:
            if cycleIndex == 1 {
                state.status.isInVerticalBlank = true
                if state.control.isNMIEnabled {
                    interruptRaiser.raiseInterrupt(.nmi)
                }
            }
        case verticalBlankLines:
            break  // Nothing for the PPU to do here, we're waiting for the display to be ready to draw again
        default:
            fatalError()
        }
    }
    
    private func populateFrameBuffer(for pixelInfo: (NESColorIndices, isSpriteZeroBeingHit: Bool)) {
        let rgbValue = rgbValueFromPaletteRAM(for: pixelInfo.0)
        let offset = state.scanlineCounter * 341 + state.cycleCounter
        framebuffer[offset] = rgbValue
    }
    
    private func handleLastCycleForScanline() {
        if state.scanlineCounter == 260 {
            state.scanlineCounter = -1
            handleLastScanlineForScreen()
        } else {
            state.scanlineCounter += 1
        }
    }
    
    private func handleLastScanlineForScreen() {
        framesCompleted += 1
        lastFrame = framebuffer  // No need to wipe `framebuffer` after this -- we're just going to write over it during the next frame!
        hasNewDisplayValues = true
    }
    
    private func mirrorIncomingAddress(_ address: UInt16) -> UInt16 {
        // Non-DMA incoming read/writes can only be to the 8 registers
        mirror(address, maxValue: 0x7)
    }
}

private extension FixedWidthInteger {
    func reversed() -> Self {
        let maxBitIndex = bitWidth - 1
        return (0...maxBitIndex).reduce(Self.zero) { partial, bit in
            var partial = partial
            partial[bit] = self[maxBitIndex - bit]
            return partial
        }
    }
}
