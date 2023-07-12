//
//  PPUAddressRanges.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/27/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

enum PPUAddressRanges {
    static let cartridge: ClosedRange<UInt16> = 0x0000...0x1fff
    static let nametables: ClosedRange<UInt16> = 0x2000...0x3eff
    static let paletteTables: ClosedRange<UInt16> = 0x3f00...0x3fff
    
    // These get mirrored throughout the `nametables` range
    static let individualNametables: [ClosedRange<UInt16>] = {
        let startAddresses: [UInt16] = [0x2000, 0x2400, 0x2800, 0x2c00]
        let size: UInt16 = 0x0400
        return startAddresses.map { ClosedRange($0..<$0 + size) }
    }()
}
