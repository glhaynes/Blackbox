//
//  Bus.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 10/7/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public protocol Bus: Addressable, AnyObject {
    var cpu: any CPU { get }
    var ppu: PPU2C02 { get }
    func tick()
    func dmaWriteToPPU(_ value: UInt8, oamMemoryAddress: UInt8)
}
