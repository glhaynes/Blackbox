//
//  SystemStatus.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/13/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public struct SystemStatus {
    public var processorState: ProcessorState
    public var cpuCycleCount: UInt64
    public var systemCycleCount: UInt64
}
