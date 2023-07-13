//
//  CartridgeLoader.swift
//  Blackbox
//
//  Created by Grady Haynes on 1/12/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation
import CoreBlackbox

enum CartridgeLoader {
    
    enum Error: Swift.Error {
        case couldNotLoadROMURL,
             couldNotParseAsINESFile(INESParser.Error),
             mapperNotSupported(UInt8)
    }
    
    static func load(romURL: URL) throws -> Cartridge {
        guard let data = Self.loadContentsOf(url: romURL) else {
            throw Error.couldNotLoadROMURL
        }
        return try Self.load(data: data, url: romURL)
    }
    
    private static func loadContentsOf(url: URL) -> Data? {
        let isSandboxExtended = url.startAccessingSecurityScopedResource()
        defer {
            if isSandboxExtended {
                url.stopAccessingSecurityScopedResource()
            }
        }
        return try? Data(contentsOf: url)
    }
    
    private static func load(data: Data, url: URL?) throws -> Cartridge {
        do {
            let iNESFile = try INESParser.parse(data)
            return try CartridgeBuilder.cartridge(for: iNESFile, url: url)
        }
        catch let error as INESParser.Error {
            throw Error.couldNotParseAsINESFile(error)
        }
        catch CartridgeBuilder.Error.mapperNotSupported(let mapperID) {
            throw Error.mapperNotSupported(mapperID)
        }
    }
}
