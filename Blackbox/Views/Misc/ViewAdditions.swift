//
//  ViewAdditions.swift
//  Blackbox
//
//  Created by Grady Haynes on 5/23/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI

// Inspired by: https://stackoverflow.com/a/59030074/3547802

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(_ condition: Bool, ifTrue trueContent: (Self) -> TrueContent, else falseContent: (Self) -> FalseContent) -> some View {
        if condition {
            trueContent(self)
        } else {
            falseContent(self)
        }
    }
}
