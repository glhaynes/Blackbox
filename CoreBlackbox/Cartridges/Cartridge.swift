//
//  Cartridge.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 10/6/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public final class Cartridge {    
    let mapper: Mapper
    let prgROM: [UInt8]
    let chrROM: [UInt8]
    let mirroring: INESFileContents.Mirroring  // TODO: Extract this
    
    init(mapper: Mapper, prgROM: [UInt8], chrROM: [UInt8], mirroring: INESFileContents.Mirroring) {
        self.mapper = mapper
        self.prgROM = prgROM
        self.chrROM = chrROM
        self.mirroring = mirroring
        mapper.cartridge = self
    }
    
    public func setInterruptRaiser(_ interruptRaiser: any InterruptRaiser) {
        mapper.interruptRaiser = interruptRaiser
    }
}
