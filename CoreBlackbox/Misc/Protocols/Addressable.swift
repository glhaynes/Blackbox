//
//  Addressable.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 8/30/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public protocol Addressable {
    func read(from address: UInt16) -> UInt8
    func write(_ value: UInt8, to address: UInt16)
}
