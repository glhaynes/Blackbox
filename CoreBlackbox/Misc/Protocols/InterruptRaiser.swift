//
//  InterruptRaiser.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 9/23/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public protocol InterruptRaiser: AnyObject {
    func raiseInterrupt(_: Interrupt)
}
