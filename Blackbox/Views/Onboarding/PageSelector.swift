//
//  PageSelector.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/12/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI

protocol SelectablePage: Hashable {
    var rawValue: String { get }
}

struct PageSelector<P: SelectablePage>: View {
    
    let pages: [P]
    @Binding var selectedPage: P

    var body: some View {
        let current = pages.firstIndex(of: selectedPage)!
        let previous = (current == pages.startIndex) ? nil : pages.index(before: current)
        let next = (current == pages.endIndex - 1) ? nil : pages.index(after: current)
        
        HStack {
            Button {
                if let previous {
                    selectedPage = pages[previous]
                }
            } label: {
                Image(systemName: previous == nil ? "arrowtriangle.left" : "arrowtriangle.left.fill")
                    .foregroundColor(previous == nil ? .secondary : .accentColor)
            }
            .buttonStyle(.borderless)
            .disabled(previous == nil)

            Picker(selection: $selectedPage) {
                ForEach(pages, id: \.self) { page in
                    Text(page.rawValue)
                }
            } label: { }
            .accessibilityLabel(Text("Page Picker"))
            .fixedSize()
            .padding(.horizontal, 5)

            Button {
                if let next {
                    selectedPage = pages[next]
                }
            } label: {
                Image(systemName: next == nil ? "arrowtriangle.right" : "arrowtriangle.right.fill")
                    .foregroundColor(next == nil ? .secondary : .accentColor)
            }
            .buttonStyle(.borderless)
            .disabled(next == nil)
        }
    }
}
