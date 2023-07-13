//
//  MainSceneController.swift
//  Blackbox
//
//  Created by Grady Haynes on 9/12/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import os.log
import SwiftUI
import Combine
import Controllers
import CoreBlackbox

@MainActor  // TODO: Not 100% sure we still need this to be @MainActor... but it (probably) doesn't hurt to keep that trait for now, at least
final class MainSceneController {
        
    private static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    private let viewModel: ViewModel
    private let logger: Logger?
    private let displayValuesManager: DisplayValuesManager
    private let onscreenControllerPressedPublisher = PassthroughSubject<Set<NESButton>, Never>()
    private let emulatorModel: EmulatorModel
    private var recentsManager: RecentsManager
    private var subscriptions: Set<AnyCancellable> = []
        
    private var welcomeViewLastShownVersion: String {
        get { UserDefaults.standard.string(forKey: "welcomeViewLastShownVersion") ?? "" }
        set { UserDefaults.standard.setValue(newValue, forKey: "welcomeViewLastShownVersion") }
    }
                        
    init(viewModel: ViewModel,
         gameControllerCoordinator: GameControllerCoordinator,
         appLogger: Logger,
         loggers: NESBuilder.Loggers = [:])
    {
        self.logger = appLogger
        
        self.viewModel = viewModel
        
        gameControllerCoordinator.setOnscreenControllerPublisher(onscreenControllerPressedPublisher)
        self.emulatorModel = EmulatorModel(nesControllers: gameControllerCoordinator.nesControllers, loggers: loggers)
        
        self.displayValuesManager = DisplayValuesManager(
            videoDisplayViewModel: viewModel.videoDisplayViewModel,
            accessoriesViewModel: viewModel.accessoriesViewModel,
            emulatorModel: emulatorModel,
            logger: appLogger)
        displayValuesManager.startVideoRefresh()

        // When the list of recent items changes, tag them with human-presentable titles and publish them
        self.recentsManager = RecentsManager(logger: appLogger)
        recentsManager.$recentLoadableROMs.sink { [unowned self] loadableROMs in
            self.viewModel.recents = Array(loadableROMs.map(\.recent)).reversed()
        }.store(in: &subscriptions)
        
        showWelcomeViewIfNeeded()
    }
    
    // MARK: Handle user commands
        
    func userOpenedRecent(_ recent: Recent) {
        switch recent.loadableROM {
        case .sampleROM:
            loadSampleROM()
        case .file(let bookmarkData, _):
            guard let url = bookmarkData.url else {
                logger?.log(level: .error, "Failed to get `url` from bookmark `Data` of size \(bookmarkData.count)")
                return
            }
            loadROMFile(url: url, title: recent.title, isSampleROM: false)
        }
    }
    
    func userImportedROMFile(url: URL) {
        loadROMFile(url: url, title: url.presentableTitle, isSampleROM: false)
    }
    
    // MARK: Emulator control
    
    func loadSampleROM() {
        guard let exampleROMURL = Bundle.main.url(forResource: "example", withExtension: "nes") else {
            logger?.log(level: .error, "Bundle does not include sample ROM `example.nes`")
            return
        }
        loadROMFile(url: exampleROMURL, title: LoadableROM.sampleROM.recent.title, isSampleROM: true)
    }
    
    private func loadROMFile(url: URL, title: String, isSampleROM: Bool) {
        let success = loadCartridge(romURL: url, title: title, isSampleROM: isSampleROM)
        if success {
            viewModel.isAnimatedBounceNeeded = true
            #if PERFORMANCE_METRICS
            // Tell the `DisplayValuesManager` that it's time to take a momentary snapshot of performance metrics
            displayValuesManager.hasAROMBeenLoaded = true
            #endif
        }
    }
    
    func reset() {
        emulatorModel.reset()
    }
                
    // MARK: Misc view support
    
    func handleOpenROM() {
        viewModel.isFileImporterShown = true
    }
    
    func updateWelcomeViewLastShownVersion() {
        welcomeViewLastShownVersion = Self.appVersion
    }

    // MARK: Onscreen Controller passthrough
    
    func buttonsPressed(_ pressed: Set<NESButton>) {
        onscreenControllerPressedPublisher.send(pressed)
    }
        
    // MARK: Misc helpers
    
    /// Returns a `Bool` representing whether the ROM was able to be loaded successfully
    private func loadCartridge(romURL: URL, title: String, isSampleROM: Bool = false) -> Bool {
        guard let cartridge = try? CartridgeLoader.load(romURL: romURL) else {
            emulatorModel.removeCartridge()
            viewModel.loadedROMTitle = nil
            return false
            // TODO: Throw instead?
            // TODO: Need to show an alert!
        }

        emulatorModel.loadCartridge(cartridge)
        viewModel.loadedROMTitle = title
        
        // Now that we've successfully loaded the ROM, add it to the recents list
        if isSampleROM {
            recentsManager.addRecentForSampleROM()
        } else {
            recentsManager.addRecent(for: romURL)
        }
        
        return true
    }
    
    private func showWelcomeViewIfNeeded() {
        // TODO: Only show this when it's never been shown or for particular upgrades. Right now we're going to show this every time the version changes.
        viewModel.isWelcomeViewShown = welcomeViewLastShownVersion != Self.appVersion
    }
}

enum LoadableROM: Codable, Hashable {
    case file(bookmarkData: Data, url: URL)
    case sampleROM

    static func ==(lhs: LoadableROM, rhs: LoadableROM) -> Bool {
        switch (lhs, rhs) {
        case (.file(let data0, let url0), .file(let data1, let url1)):
            // TODO: Confirm this is the best way to do this
            return data0 == data1 || url0 == url1
        case (.sampleROM, .sampleROM):
            return true
        default:
            return false
        }
    }
}

struct Recent: Hashable {
    let title: String
    let loadableROM: LoadableROM
}

private extension LoadableROM {
    var recent: Recent {
        // TODO: Update to Swift 5.9
        let title: String
        switch self {
        case .sampleROM:
            title = "Sample ROM"
        case .file(_, let url):
            title = url.presentableTitle
        }
        return .init(title: title, loadableROM: self)
    }
}

private extension URL {
    var presentableTitle: String {
        self.deletingPathExtension().lastPathComponent
    }
}

private extension Data {
    /// Returns a `URL` if the Data is interpretable as a URL bookmark, or nil if it isn’t.
    var url: URL? {
        #if os(macOS)
        let options: URL.BookmarkResolutionOptions = [.withSecurityScope]
        #else
        let options: URL.BookmarkResolutionOptions = []
        #endif
        
        var bookmarkDataIsStale = false
        let url = try? URL(resolvingBookmarkData: self, options: options, bookmarkDataIsStale: &bookmarkDataIsStale)
        if url == nil || bookmarkDataIsStale {
            // TODO: Deal with these situations
        }
        return url
    }
}
