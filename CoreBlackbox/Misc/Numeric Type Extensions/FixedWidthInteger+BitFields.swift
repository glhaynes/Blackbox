//
//  FixedWidthInteger+BitFields.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/10/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

extension FixedWidthInteger {
    static func bitmask(for range: ClosedRange<Int>) -> Self {
        assert(range.lowerBound >= 0 && range.upperBound <= bitWidth - 1)
        var result: Self = 0
        for bitIndex in range {
            result |= 1 << bitIndex
        }
        return result
    }
    
    func bits(_ range: ClosedRange<Int>) -> Self {
        assert(range.upperBound <= bitWidth)
        return self & Self.bitmask(for: range)
    }
}
