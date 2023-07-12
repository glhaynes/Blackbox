//
//  Wedge.swift
//  Blackbox
//
//  Created by Grady Haynes on 1/13/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI

struct Wedge: Shape {

    let radius: Double
    let width: Angle
        
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.midY))
            path.addArc(center: .init(x: rect.midX, y: rect.midY),
                        radius: radius,
                        startAngle: .zero - width / 2,
                        endAngle: width / 2,
                        clockwise: false)
        }
    }
}
