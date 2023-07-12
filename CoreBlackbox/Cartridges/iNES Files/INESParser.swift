//
//  INESParser.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/7/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public enum INESParser {

    public static func parse(_ data: Data) -> INESFileContents? {
        
        // TODO: Would be nicer to use exceptions
        
        guard data.count >= 4, magic(from: Array(data[0...3])) == 0x4e45531a else {
            return nil
        }
        
        guard data.count >= 9 else {
            return nil
        }

        let prgROMCount = Int(data[4])
        guard prgROMCount > 0 else { return nil }
        let chrROMCount = Int(data[5])
        guard chrROMCount > 0 else { return nil }
        let flags6 = data[6]
        let flags7 = data[7]
        let prgRAMSize = Int(data[8])
        guard prgRAMSize >= 0 else { return nil }

        let isIncludingTrainer = (flags6 & 0x04) != 0  // TODO: Document what a trainer is
        
        let mirroring: INESFileContents.Mirroring = flags6.bits(0...0) == 1 ? .vertical : .horizontal
        
        let prgROMSizeEach = 16384  // TODO: Don't hardcode this; this change will be needed to support more ROMs
        let prgROMsBaseOffset = 16 + (isIncludingTrainer ? 512 : 0)
        let prgROMsTotalSize = prgROMCount * prgROMSizeEach
        
        let chrROMSizeEach = 8192
        let chrROMsBaseOffset = prgROMsBaseOffset + prgROMsTotalSize
        let chrROMsTotalSize = chrROMCount * chrROMSizeEach
        
        guard data.count >= max(prgROMsBaseOffset + prgROMsTotalSize,
                                chrROMsBaseOffset + chrROMsTotalSize)
        else { return nil }
        
        let prgROM = Array(data[prgROMsBaseOffset..<prgROMsBaseOffset + prgROMsTotalSize])
        let chrROM = Array(data[chrROMsBaseOffset..<chrROMsBaseOffset + chrROMsTotalSize])

        let mapperID = (flags7 & 0xf0) | (flags6 >> 4)
        
        return INESFileContents(mapperID: mapperID, prgRAMSize: prgRAMSize, prgROM: prgROM, chrROM: chrROM, mirroring: mirroring)
    }
    
    private static func magic(from bytes: [UInt8]) -> UInt32 {
        UInt32(bytes[0]) << 24 |
        UInt32(bytes[1]) << 16 |
        UInt32(bytes[2]) << 8  |
        UInt32(bytes[3])
    }
}
