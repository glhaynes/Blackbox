//
//  ProcessorInterruptRequestView.swift
//  Blackbox
//
//  Created by Grady Haynes on 9/6/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import SwiftUI
import CoreBlackbox

struct ProcessorInterruptRequestView: View {
    
    private static let irqStrings: [ProcessorState.IRQ: String] = [
        .none: "No",
        .regular: "Yes",
        .nonMaskable: "Yes (NMI)",
        .reset: "Reset"
    ]

    var irq: ProcessorState.IRQ
    
    var body: some View {
        Text(Self.irqStrings[irq] ?? "")
            .bold()
    }
}

struct ProcessorInterruptRequestView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessorInterruptRequestView(irq: .regular)
            .previewLayout(.sizeThatFits)
    }
}
