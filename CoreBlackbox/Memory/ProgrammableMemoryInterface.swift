//
//  ProgrammableMemoryInterface.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/5/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import Foundation

public final class ProgrammableMemoryInterface: Addressable {
    
    private let baseAddress: UInt16
    private let addressTranslator: (UInt16) -> UInt16
    private let logger: Logger?

    private var bufferBox: BufferBox

    // TODO: Add an init that lets it make its own BufferBox in instances where we don't care about setting it (i.e. all those where we just make something up right there on the spot to give it)
    
    public init(baseAddress: UInt16, bufferBox: BufferBox, addressTranslator: @escaping (UInt16) -> UInt16 = { $0 }, logger: Logger? = nil) {
        self.baseAddress = baseAddress
        self.addressTranslator = addressTranslator
        self.bufferBox = bufferBox
        self.logger = logger
    }

    public func read(from address: UInt16) -> UInt8 {
        let translatedAddress = addressTranslator(address)
        let realAddress = translatedAddress - baseAddress
        let value = bufferBox.bytes[Int(realAddress)]
        logInfoPublicly(CPULog.memoryAccess(.read(from: address, value: value)).string)  // TODO: This isn't the CPU so shouldn't be CPULog!
        return value
    }

    public func write(_ value: UInt8, to address: UInt16) {
        let translatedAddress = addressTranslator(address)
        let realAddress = translatedAddress - baseAddress
        if logger != nil {
            let oldValue = bufferBox.bytes[Int(realAddress)]
            logInfoPublicly(CPULog.memoryAccess(.write(to: address, value: value, replacing: oldValue)).string)  // TODO: This isn't the CPU so shouldn't be CPULog!
        }
        bufferBox.bytes[Int(realAddress)] = value
    }
    
    private func logInfoPublicly(_ string: String) {
        // TODO: Commented out for speed
        //logger?.info("\(string, privacy: .public)")
    }
}
