//
//  MainScene.swift
//  Blackbox
//
//  Created by Grady Haynes on 1/10/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import os.log
import SwiftUI
import Combine
import Controllers
import CoreBlackbox

struct MainScene: Scene {
    
    @AppStorage("areAccessoriesPreferredShown") private var areAccessoriesPreferredShown = true
    
    @StateObject private var viewModel: ViewModel
    @ObservedObject private var gameControllerCoordinator: GameControllerCoordinator
    private let controller: MainSceneController
    
    init(gameControllerCoordinator: GameControllerCoordinator,
         appLogger: Logger,
         loggers: NESBuilder.Loggers = [:]
    ) {
        self.gameControllerCoordinator = gameControllerCoordinator
        
        let viewModel = ViewModel()
        _viewModel = StateObject(wrappedValue: viewModel)
        controller = MainSceneController(viewModel: viewModel,
                                         gameControllerCoordinator: gameControllerCoordinator,
                                         appLogger: appLogger,
                                         loggers: loggers)
    }
    
    var body: some Scene {
        WindowGroup {
            let mainMenuContentModelWrapper = MainMenuContentModelWrapper(controller: controller, viewModel: viewModel)
            MainView(userImportedFile: controller.userImportedROMFile,
                     welcomeViewDismissed: controller.updateWelcomeViewLastShownVersion)
                .environmentObject(viewModel)
                .environmentObject(viewModel.videoDisplayViewModel)
                .environmentObject(viewModel.accessoriesViewModel)
                .environment(\.mainMenuContent, MainMenuContent(modelWrapper: mainMenuContentModelWrapper))
                .environment(\.shouldOnscreenControllerBeShown, gameControllerCoordinator.shouldOnscreenControllerBeShown)
                .environment(\.onscreenButtonsPressed, controller.buttonsPressed)
                #if os(macOS)
                .frame(minWidth: 1000, minHeight: 600)
                #endif
        }
        .commands {
            MainCommands(controller: controller,
                         isAboutViewShown: $viewModel.isAboutViewShown,
                         isWelcomeViewShown: $viewModel.isWelcomeViewShown,
                         areAccessoriesPreferredShown: $areAccessoriesPreferredShown)
            .commands(recents: viewModel.recents)
        }
    }
}

struct MainMenuContentKey: EnvironmentKey {
    static let defaultValue = MainMenuContent(modelWrapper: MainMenuContentModelWrapper())
}

struct ShouldOnscreenControllerBeShownKey: EnvironmentKey {
    static let defaultValue = false
}

struct OnscreenButtonsPressedKey: EnvironmentKey {
    static let defaultValue: @MainActor (Set<NESButton>) -> Void = { _ in }
}

extension EnvironmentValues {
    var mainMenuContent: MainMenuContent {
        get { self[MainMenuContentKey.self] }
        set { self[MainMenuContentKey.self] = newValue }
    }

    var shouldOnscreenControllerBeShown: Bool {
        get { self[ShouldOnscreenControllerBeShownKey.self] }
        set { self[ShouldOnscreenControllerBeShownKey.self] = newValue }
    }
    
    var onscreenButtonsPressed: @MainActor (Set<NESButton>) -> Void {
        get { self[OnscreenButtonsPressedKey.self] }
        set { self[OnscreenButtonsPressedKey.self] = newValue }
    }
}
