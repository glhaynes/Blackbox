//
//  CartridgeBuilder.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 10/6/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public enum CartridgeBuilder {
    
    public enum Error: Swift.Error {
        case mapperNotSupported(UInt8)
    }
    
    public static func cartridge(for file: INESFileContents, url: URL?) throws -> Cartridge {
        guard let mapper = MapperBuilder.mapper(forID: Int(file.mapperID)) else {
            throw Error.mapperNotSupported(file.mapperID)
        }
        return Cartridge(mapper: mapper, prgROM: file.prgROM, chrROM: file.chrROM, mirroring: file.mirroring)
    }
}
