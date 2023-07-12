//
//  PPURAMAddressTranslator.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/27/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

enum PPURAMAddressTranslator {
    
    static func paletteTableIndex(forAddress address: UInt16) -> Int {
        var address = mirror(address, maxValue: 0x001f)

        // NESDev: "Addresses $3F10/$3F14/$3F18/$3F1C are mirrors of $3F00/$3F04/$3F08/$3F0C. Note that this goes for writing as well as reading. A symptom of not having implemented this correctly in an emulator is the sky being black in Super Mario Bros., which writes the backdrop color through $3F10."
        if [0x0010, 0x0014, 0x0018, 0x001c].contains(address) {
            address = mirror(address, maxValue: 0x000f)
        }
        
        return Int(address)
    }

    //    private func paletteTableRAMEntry(forAddress address: UInt16) -> UInt8 {
//        paletteTableRAM[Int(address)] & (state.mask.isGrayscale ? 0x30 : 0x3f)
//    }
    
    // --------------------------------------------------
    
    static func nametableLocation(forAddress address: UInt16, cartMirror: INESFileContents.Mirroring) -> (id: Int, offset: Int) {
        let nametableIndex: Int
        switch (cartMirror, address) {
        case (.vertical, PPUAddressRanges.individualNametables[0]),
             (.vertical, PPUAddressRanges.individualNametables[2]):
            nametableIndex = 0
        case (.vertical, PPUAddressRanges.individualNametables[1]),
             (.vertical, PPUAddressRanges.individualNametables[3]):
            nametableIndex = 1
        case (.horizontal, PPUAddressRanges.individualNametables[0]),
             (.horizontal, PPUAddressRanges.individualNametables[1]):
            nametableIndex = 0
        case (.horizontal, PPUAddressRanges.individualNametables[2]),
             (.horizontal, PPUAddressRanges.individualNametables[3]):
            nametableIndex = 1
        default:
            fatalError()
        }
        
        let offset = Int(address.bits(0...9))
        
        return (nametableIndex, offset)
    }
    
    static func nametableRAMIndex(forNametableIndex index: Int, offset: Int) -> Int {
        index * 1024 + offset
    }
    
    // --------------------------------------------------
    
    static func indicesForOAMAddress(_ oamAddress: UInt8) -> (entryIndex: Int, byteIndex: Int) {
        let oamAddress = Int(oamAddress)
        return (oamAddress / 4, oamAddress % 4)
    }
    
    // TODO: Consider whether to use this a few more places - or drop it entirely. Maybe add it to the UInt16 extensions or make it a private top-level?
    private static func mirror<T: UnsignedInteger>(_ address: T, maxValue: T) -> T {
        address & maxValue
    }
}
