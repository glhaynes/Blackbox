//
//  MainMenuContent.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/20/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation
import SwiftUI

struct MainMenuContent: View {
    
    @ObservedObject var modelWrapper: MainMenuContentModelWrapper
    
    var body: some View {
        Button {
            modelWrapper.controller?.handleOpenROM()
        } label: {
            Label("Open ROM…", systemImage: "doc.badge.ellipsis")
        }
        
        Button {
            modelWrapper.controller?.loadSampleROM()
        } label: {
            Label("Open Sample ROM", systemImage: "doc.text")
        }
                    
        Button {
            modelWrapper.controller?.reset()
        } label: {
            Label("Reset", systemImage: "restart.circle")
        }
        
        Divider()
        
        #if !os(macOS)
        Button {
            modelWrapper.viewModel?.isSettingsViewShown = true
        } label: {
            Label("Settings…", systemImage: "gearshape")
        }
        #endif
                
        Divider()

        Menu("Recently Played") {
            ForEach(modelWrapper.viewModel?.recents ?? [], id: \.self) { recent in
                Button {
                    modelWrapper.controller?.userOpenedRecent(recent)
                } label: {
                    Text("\(recent.title)")
                }
            }
        }
        
        Divider()
        
        Button {
            modelWrapper.viewModel?.isWelcomeViewShown = true
        } label: {
            Label("Help", systemImage: "questionmark.circle")
        }
    }
}

// TODO: Remove this while moving to `Observation`, assuming that's possible
/// Wrapper class used because we can't observe an optional. Probably not the best solution.
final class MainMenuContentModelWrapper: ObservableObject {
    /*@Published*/ var controller: MainSceneController?
    var viewModel: ViewModel?
    init(controller: MainSceneController? = nil, viewModel: ViewModel? = nil) {
        self.controller = controller
        self.viewModel = viewModel
    }
}
