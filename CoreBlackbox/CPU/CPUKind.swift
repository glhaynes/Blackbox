//
//  CPUKind.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/13/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public enum CPUKind {
    /// C-language, cycle-steppable 6502 emulator. Can be used for unit testing or to run games.
    ///
    /// From floooh’s “chips” project: https://github.com/floooh/chips
    ///
    /// See also: https://floooh.github.io/2019/12/13/cycle-stepped-6502.html
    case m6502
    
    /// Swift-native 6502 emulator. Part of the `CoreBlackbox` project. Can be used for unit testing but is not (yet) usable to run games.
    case cpu6502
}
