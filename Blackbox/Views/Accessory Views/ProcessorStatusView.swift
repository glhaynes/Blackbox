//
//  ProcessorStatusView.swift
//  Blackbox
//
//  Created by Grady Haynes on 9/6/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import SwiftUI
import CoreBlackbox

struct ProcessorStatusView: View {
    
    private static let base = "NV-BDIZC"
    private static let baseAttributedString = AttributedString(base)
    private static let charactersToBits = zip(base.map(String.init), ProcessorState.ProcessorStatusRegister.Bit.allCases)
    
    var psr: ProcessorState.ProcessorStatusRegister
    
    var body: some View {
        Text(attributedString(for: psr))
            .monospaced()
    }
    
    private func attributedString(for p: ProcessorState.ProcessorStatusRegister) -> AttributedString {
        var attributedString = Self.baseAttributedString
        for (character, bit) in Self.charactersToBits {
            guard let range = attributedString.range(of: character) else { continue }
            if p[bit] {
                attributedString[range].inlinePresentationIntent = .stronglyEmphasized
                attributedString[range].swiftUI.backgroundColor = .accentColor.opacity(0.5)
            }
        }
        return attributedString
    }
}

struct ProcessorStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessorStatusView(psr: .init(integerLiteral: 22))
            .previewLayout(.sizeThatFits)
    }
}
