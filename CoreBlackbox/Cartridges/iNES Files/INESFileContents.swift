//
//  INESFileContents.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/8/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public struct INESFileContents {
    
    public enum Mirroring {
        case vertical, horizontal
    }
    
    public let mapperID: UInt8
    public let prgRAMSize: Int  // TODO: Add prgRAM
    public let prgROM: [UInt8]
    public let chrROM: [UInt8]
    public let mirroring: Mirroring
}
