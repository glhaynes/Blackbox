//
//  AccessoriesViewModel.swift
//  Blackbox
//
//  Created by Grady Haynes on 1/9/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI
import CoreBlackbox

final class AccessoriesViewModel: ObservableObject {
    @Published var cpuState: ProcessorState
    @Published var cpuCycleCount: UInt64
    @Published var patternTables: (CGImage, CGImage)?
    @Published var systemPalette: SystemPalette?
    
    init(cpuState: ProcessorState = .init(a: 0, x: 0, y: 0, s: 0, pc: 0, p: 0),
         cpuCycleCount: UInt64 = 0,
         patternTables: (CGImage, CGImage)? = nil,
         systemPalette: SystemPalette? = nil)
    {
        self.cpuState = cpuState
        self.cpuCycleCount = cpuCycleCount
        self.patternTables = patternTables
        self.systemPalette = systemPalette
    }
}
