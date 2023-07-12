//
//  KeyboardPage.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/21/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation
import SwiftUI

struct KeyboardPage: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    #else
    // TODO: On macOS ≥ 14, this is no longer needed
    // TODO: In the meantime, consider replacing with this: https://mastodon.social/@lightandshadow/110515168557081092
    let horizontalSizeClass: MacOSStubSizeClass = .regular
    let verticalSizeClass: MacOSStubSizeClass = .regular
    #endif
    
    let spacing: CGFloat
    
    var body: some View {
        TitledContent(title: "Play using a keyboard", symbolName: "keyboard") {
            let string = string(for: [
                ("       Tab", "Select"),
                ("    Return", "Start"),
                ("         A", "B"),
                ("         S", "A"),
                ("Arrow keys", "Control Pad")
            ])
            
            Text(string)
                .font(monoFont)
                .monospaced()
        }
    }
    
    private var monoFont: Font {
        let isCompact = [horizontalSizeClass, verticalSizeClass].contains(.compact)
        return isCompact ? .headline : .title3
    }

    private func string(for stringPairs: [(String, String)]) -> String {
        return stringPairs.map { left, right in
            "\(left): \(right)"
        }.joined(separator: "\n")
    }
}
