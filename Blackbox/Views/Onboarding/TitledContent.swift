//
//  TitledContent.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/12/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI

struct TitledContent<C: View>: View {
    
    @Environment(\.colorScheme) private var colorScheme
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    #else
    // TODO: On macOS ≥ 14, this is no longer needed
    // TODO: In the meantime, consider replacing with this: https://mastodon.social/@lightandshadow/110515168557081092
    let horizontalSizeClass = MacOSStubSizeClass.regular
    let verticalSizeClass = MacOSStubSizeClass.regular
    #endif

    // TODO: Maybe this should use `LabeledContent`?
    
    private let title: String
    private let symbolName: String
    @ViewBuilder private let content: () -> C
        
    init(title: String, symbolName: String, @ViewBuilder content: @escaping () -> C) {
        self.title = title
        self.symbolName = symbolName
        self.content = content
    }
    
    var body: some View {
        if [verticalSizeClass, horizontalSizeClass].contains(.compact) {
            compact
        } else {
            nonCompact
        }
    }
    
    private var compact: some View {
        VStack {
            HStack(spacing: 20) {
                Image(systemName: symbolName)
                    .font(.system(size: 35))
                    .foregroundStyle(Color.accentColor)
                Title(title)
            }
            
            Divider().hidden()

            content()
        }
        .padding(.horizontal, 20)
    }
    
    private var nonCompact: some View {
        VStack {
            VStack {
                Image(systemName: symbolName)
                    .font(.system(size: 60))
                    .foregroundStyle(Color.accentColor)
                Divider().hidden()
                Title(title)
            }
            
            Divider().hidden()

            content()
                .padding([.horizontal], 40)
        }
    }
}

private struct Title: View {
    
    @Environment(\.colorScheme) private var colorScheme
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    #else
    // TODO: On macOS ≥ 14, this is no longer needed
    // TODO: In the meantime, consider replacing with this: https://mastodon.social/@lightandshadow/110515168557081092
    let horizontalSizeClass = MacOSStubSizeClass.regular
    let verticalSizeClass = MacOSStubSizeClass.regular
    #endif
    
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        let isCompact = [horizontalSizeClass, verticalSizeClass].contains(.compact)
        let font: Font = isCompact ? .title : .largeTitle
        let color: Color = colorScheme == .light ? .black : .white
        
        Text(title)
            .font(font)
            .foregroundColor(color)
            .multilineTextAlignment(.leading)
    }
}
