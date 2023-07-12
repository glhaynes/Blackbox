//
//  PPURegisterAddress.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/27/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

enum PPURegisterAddress {
    static let control: UInt16 = 0x0000
    static let mask: UInt16 = 0x0001
    static let status: UInt16 = 0x0002
    static let oamAddress: UInt16 = 0x0003
    static let oamData: UInt16 = 0x0004
    static let scroll: UInt16 = 0x0005
    static let address: UInt16 = 0x0006
    static let data: UInt16 = 0x0007
}
