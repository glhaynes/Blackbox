//
//  GameControllersPage.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/21/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation
import SwiftUI

struct GameControllersPage: View {
    
    enum ControllerKind: CaseIterable {
        case nintendo, sony, xbox
    }
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    #else
    // TODO: On macOS ≥ 14, this is no longer needed
    // TODO: In the meantime, consider replacing with this: https://mastodon.social/@lightandshadow/110515168557081092
    let horizontalSizeClass: MacOSStubSizeClass = .regular
    let verticalSizeClass: MacOSStubSizeClass = .regular
    #endif
    
    @Binding var selectedControllerKind: ControllerKind
    
    let spacing: CGFloat
    
    var body: some View {
        TitledContent(title: "Play using a game controller", symbolName: "gamecontroller") {
            VStack {
                #if canImport(AppKit)
                let needsLabel = false
                #else
                let needsLabel = true
                #endif
                
                LabeledContent {
                    Picker("Type:", selection: $selectedControllerKind) {
                        Text("Nintendo").tag(ControllerKind.nintendo)
                        Text("Sony").tag(ControllerKind.sony)
                        Text("Xbox").tag(ControllerKind.xbox)
                    }
                } label: {
                    if needsLabel {
                        Text("Type")
                    }
                }
                .fixedSize()
                
                Divider().hidden()
                
                Text(stringForKind(selectedControllerKind))
                    .font(monoFont)
                    .monospaced()
            }
        }
    }
    
    private var monoFont: Font {
        let isCompact = [horizontalSizeClass, verticalSizeClass].contains(.compact)
        return isCompact ? .headline : .title3
    }
    
    private func stringForKind(_ kind: ControllerKind) -> String {
        formatted(unformattedStringPairs(for: kind))
    }
    
    private func formatted(_ stringPairs: [(String, String)]) -> String {
        return stringPairs.map { left, right in
            if !left.isEmpty {
                return "\(left): \(right)"
            } else {
                return "\(left) \(right)"
            }
        }.joined(separator: "\n")
    }
    
    private func unformattedStringPairs(for kind: ControllerKind) -> [(String, String)] {
        switch kind {
        case .nintendo:
            return [
                ("", ""),
                ("Y", "Select"),
                ("X", "Start"),
                ("", "")
            ]
        case .sony:
            return [
                ("□", "Select"),
                ("▵", "Start"),
                ("×", "B"),
                ("○", "A")
            ]
        case .xbox:
            return [
                ("X", "Select"),
                ("Y", "Start"),
                ("A", "B"),
                ("B", "A")
            ]
        }
    }
}
