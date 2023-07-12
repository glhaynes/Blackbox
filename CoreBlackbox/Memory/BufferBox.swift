//
//  BufferBox.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/13/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public final class BufferBox {

    public var bytes: [UInt8]
    
    public init(size: Int) {
        self.bytes = .init(repeating: .zero, count: size)
    }
}
