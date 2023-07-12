//
//  ProcessorRegisterView.swift
//  Blackbox
//
//  Created by Grady Haynes on 9/6/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import SwiftUI
import CoreBlackbox

struct ProcessorRegisterView: View {
    
    var ps: ProcessorState

    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                Text("A:")
                Text("X:")
                Text("Y:")
                Text("S:")
                Text("PC:")
            }
            
            VStack(alignment: .leading) {
                Text(ps.a.hexString)
                Text(ps.x.hexString)
                Text(ps.y.hexString)
                Text(ps.s.hexString)
                Text(ps.pc.hexString)
            }
            .bold()
        }
        .monospaced()
    }
}

struct ProcessorRegisterView_Previews: PreviewProvider {
    private static let ps = ProcessorState(a: 2, x: 32, y: 16, s: 0xff, pc: 0xfffc, p: 0)
    
    static var previews: some View {
        ProcessorRegisterView(ps: ps)
            .previewLayout(.sizeThatFits)
    }
}
