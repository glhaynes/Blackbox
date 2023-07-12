//
//  Mapper.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 10/6/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public protocol Mapper: AnyObject {
    var cartridge: Cartridge! { get set }
    var interruptRaiser: (any InterruptRaiser)? { get set }
    
    init()
    
    func scanlineRenderingWasCompletedByPPU()
    func read(from address: UInt16) -> UInt8?
    func write(_ value: UInt8, to address: UInt16) -> Bool
}
