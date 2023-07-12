//
//  MainCommands.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/13/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI

struct MainCommands {
    
    let controller: MainSceneController
    let isAboutViewShown: Binding<Bool>
    let isWelcomeViewShown: Binding<Bool>
    let areAccessoriesPreferredShown: Binding<Bool>
    // TODO: Should these bindings just be handled through `controller`?
    
    @CommandsBuilder
    func commands(recents: [Recent]) -> some Commands {
        
        CommandGroup(replacing: .appInfo) {
            Button("About Blackbox") {
                isAboutViewShown.wrappedValue.toggle()
            }
        }
        
        CommandGroup(replacing: .newItem) {
            Button("Open ROM…") {
                Task { @MainActor in
                    controller.handleOpenROM()
                }
            }
            .keyboardShortcut("O")
            
            Button("Open Sample ROM") {
                Task { @MainActor in
                    controller.loadSampleROM()
                }
            }
            .keyboardShortcut("O", modifiers: [.shift, .command])
            
            Menu("Open Recent") {
                ForEach(recents, id: \.self) { recent in
                    Button {
                        Task { @MainActor in
                            controller.userOpenedRecent(recent)
                        }
                    } label: {
                        Text("\(recent.title)")
                    }
                }
            }
            .disabled(recents.isEmpty)  // TODO: Disabling doesn't work!
            
            Button("Reset") {
                Task { @MainActor in
                    controller.reset()
                }
            }
            .keyboardShortcut("R")
        }

        CommandGroup(replacing: .toolbar) {  // .toolbar is the "View" menu
            // TODO: Disable this when it should be unavailable (similar to when toolbar buttons are unavailable)
            Toggle(isOn: areAccessoriesPreferredShown) {
                Text("Show Accessories")
            }
            .keyboardShortcut("0")
        }
        
        CommandGroup(replacing: .help) {
            Button("Blackbox Help") {
                isWelcomeViewShown.wrappedValue.toggle()
            }
        }
    }
}
