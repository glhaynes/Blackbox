//
//  TestHelpers.swift
//  CoreBlackboxTests
//
//  Created by Grady Haynes on 9/3/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import Foundation
@testable import CoreBlackbox

//
// TODO :
//
//  - Get unit tests to where they can be run with both CPU kinds based on environment variables…
//  - And do actually run both ways!
//  - (Make sure this works in Xcode Cloud.)
//

// Globals
let cpuKind: CPUKind = .cpu6502
let defaultTestingLogger = Logger(subsystem: "com.wordparts.Blackbox", category: "Unit Tests")
