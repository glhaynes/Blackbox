//
//  CPUKind.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/13/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public enum CPUKind {
    /// Swift-native 6502 emulator. Part of the `CoreBlackbox` project.
    case cpu6502

    /// C-language, cycle-steppable 6502 emulator.
    ///
    /// From floooh’s “chips” project: https://github.com/floooh/chips
    ///
    /// See also: https://floooh.github.io/2019/12/13/cycle-stepped-6502.html
    case m6502
}
