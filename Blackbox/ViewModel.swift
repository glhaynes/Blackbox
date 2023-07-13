//
//  ViewModel.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/30/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI
import CoreBlackbox

@MainActor
final class ViewModel: ObservableObject {
    
    struct ErrorContent: Identifiable {
        let id = UUID()
        let details: Details
        
        enum Details {
            case errorOpeningCartridge(CartridgeLoader.Error)
        }
    }
    
    @Published var isFileImporterShown = false
    @Published var isSettingsViewShown = false
    @Published var isWelcomeViewShown = false
    @Published var isAboutViewShown = false
    @Published var isAnimatedBounceNeeded = false
    @Published var loadedROMTitle: String?
    @Published var errorContent: ErrorContent?
    var recents: [Recent] = []
    var videoDisplayViewModel = VideoDisplayViewModel()
    var accessoriesViewModel = AccessoriesViewModel()
    
    nonisolated init() {
        // TODO: This is needed only for `MainView_Previews`...?
    }
}
