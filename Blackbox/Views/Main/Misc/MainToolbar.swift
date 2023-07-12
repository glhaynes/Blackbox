//
//  MainToolbar.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/3/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI

struct MainToolbar: ToolbarContent {
    
    #if os(iOS)
    @Environment(\.mainMenuContent) var mainMenuContent
    #endif
    @Binding var isWelcomeViewShown: Bool
    @Binding var areAccessoriesPreferredShown: Bool
    let isAccessoriesButtonAvailable: Bool

    #if os(macOS)
    var body: some ToolbarContent {        
        ToolbarItemGroup(placement: .primaryAction) {
            HStack {
                Button {
                    Task { @MainActor in
                        isWelcomeViewShown.toggle()
                    }
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .help("Blackbox Help")
                
                Divider()
                
                Button {
                    areAccessoriesPreferredShown.toggle()
                } label: {
                    Image(systemName: "sidebar.squares.trailing")
                }
                .help("Hide or show accessories")
            }
        }
    }
    #endif
    
    #if os(iOS)
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Menu {
                mainMenuContent
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            
            Button {
                areAccessoriesPreferredShown.toggle()
            } label: {
                Image(systemName: "sidebar.squares.trailing")
            }
            .disabled(!isAccessoriesButtonAvailable)
        }
    }
    #endif
}
