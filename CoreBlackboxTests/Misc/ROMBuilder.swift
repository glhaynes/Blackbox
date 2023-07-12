//
//  ROMBuilder.swift
//  CoreBlackboxTests
//
//  Created by Grady Haynes on 9/8/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import Foundation
@testable import CoreBlackbox

// TODO: Gut this now that we've made CartridgeBuilder - turn this into just stuff for unit testing

struct ROMBuilder {
          
    static func rom(prgROM: [UInt8],
                           startingAt: UInt16,
                           resetVectorInitialValue: UInt16? = nil,
                           isNestest: Bool = false,
                           logger: Logger?) -> (Addressable, BufferBox) {
        var addressable: Addressable
        let bufferBox: BufferBox
        if isNestest {
            // This is because Nestest has only a single 16 KB PRG-ROM so it needs to be mirrored at 0xc000
            //memoryInterface = ProgrammableMemoryInterface(logger: logger, size: 64 * 1024, addressTranslator: { (0xc000...0xffff).contains($0) ? $0 - 0x4000 : $0 })
            
            // This should probably use `startingAt` (which is 0x8000, right?)
            
            bufferBox = BufferBox(size: 32 * 1024)
            //let size = 32 * 1024
            addressable = ProgrammableMemoryInterface(baseAddress: 0x8000, bufferBox: bufferBox, addressTranslator: { address in
                let range: ClosedRange<UInt16> = 0x8000...0xffff
                assert(range.contains(address))
                
                switch prgROM.count {
                case 16384:
                    // DK needs mirroring
                    return address & 0xbfff
                case 32768:
                    // SMB needs the whole space
                    return address
                default:
                    fatalError()
                }
            },
            logger: logger)
        } else {
            bufferBox = BufferBox(size: 64 * 1024)
            addressable = ProgrammableMemoryInterface(baseAddress: 0, bufferBox: bufferBox, logger: logger)
        }

        let range = UInt16(startingAt)...UInt16(startingAt) + UInt16(prgROM.count - 1)
        zip(prgROM, range).forEach { value, address in
            addressable.write(value, to: address)   // TODO: This breaks all non-isNestest, I think!
        }
        
//        if !isNestest {
        if let resetVectorInitialValue {
            // Set up reset vector
            let startAt = resetVectorInitialValue //?? startingAt
            let resetVectorBase = UInt16(0xfffc)
            addressable.write(startAt.lowByte, to: resetVectorBase)
            addressable.write(startAt.highByte, to: resetVectorBase &+ 1)
        }
        
        return (addressable, bufferBox)
    }
}
