//
//  MainView.swift
//  Blackbox
//
//  Created by Grady Haynes on 9/29/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import SwiftUI

struct MainView: View {
    
    // TODO: Some transitions in this view need to be modified when Accessibility > Reduce Motion is set
    // TODO: Bring back the `MemoryView` (and add editing to it)
    
    private static let isInPreviewMode = {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }()

    let userImportedFile: (@MainActor (URL) -> Void)?
    let welcomeViewDismissed: (@MainActor () -> Void)?

    @AppStorage("areAccessoriesPreferredShown") private var areAccessoriesPreferredShown = true
    @AppStorage("isOnscreenControllerPreferredAlwaysShown") private var isOnscreenControllerPreferredAlwaysShown = false
    @AppStorage("onscreenControllerPreferredOpacity") private var onscreenControllerPreferredOpacity = 0.2
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    #if canImport(UIKit)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.shouldOnscreenControllerBeShown) private var shouldOnscreenControllerBeShown
    #else
    private let horizontalSizeClass = MacOSStubSizeClass.regular
    private let verticalSizeClass = MacOSStubSizeClass.regular
    @Environment(\.mainMenuContent) private var mainMenuContent
    @Environment(\.openWindow) private var openWindow
    #endif
    
    @EnvironmentObject private var viewModel: ViewModel

    @State private var gameScreenScale = 1.0
    @State private var mainContentSize: CGSize = .zero
    
    private let background = Color("Background").gradient

    // MARK: Main Body
    
    init(userImportedFile: (@MainActor (URL) -> Void)? = nil, welcomeViewDismissed: (@MainActor () -> Void)? = nil) {
        self.userImportedFile = userImportedFile
        self.welcomeViewDismissed = welcomeViewDismissed
    }
        
    var body: some View {
        bodyContent
            .persistentSystemOverlays(.hidden)
            .alert(item: $viewModel.errorContent) { content in
                Alert(title: Text("Could not Open ROM File"), message: Text(string(for: content.details)))
            }
            #if os(macOS)
            .onChange(of: viewModel.isAboutViewShown) { value in
                guard value else { return }
                openWindow(id: "About")
            }
            #endif
            #if os(iOS)
            .sheet(isPresented: $viewModel.isSettingsViewShown) {
                NavigationStack {
                    settings
                }
            }
            #endif
            .sheet(isPresented: $viewModel.isWelcomeViewShown,
                   onDismiss: { Task { @MainActor in welcomeViewDismissed?() } }) {
                NavigationStack {
                    WelcomeView()
                }
                .presentationBackground(.thinMaterial)
                #if os(macOS)
                // TODO: Why do we do this versus this?
                // - https://developer.apple.com/documentation/swiftui/scene/defaultsize(_:)
                .frame(width: 500, height: 550)
                #endif
            }
            .fileImporter(isPresented: $viewModel.isFileImporterShown, allowedContentTypes: [.nesROM]) {
                guard let url = try? $0.get() else { return }
                Task { @MainActor in
                    userImportedFile?(url)
                }
            }
            .onChange(of: viewModel.isAnimatedBounceNeeded) { isNeeded in
                guard isNeeded else { return }
                animateBounce()
            }
    }
        
    #if os(macOS)
    private var bodyContent: some View {
        ZStack {
            DisableSystemAlertSoundsView()
            
            GeometryReader { geo in
                VideoDisplayAndShownAccessories(areAccessoriesShown: areAccessoriesShown, gameScreenScale: gameScreenScale)
                    .toolbar {
                        MainToolbar(isWelcomeViewShown: $viewModel.isWelcomeViewShown,
                                    areAccessoriesPreferredShown: $areAccessoriesPreferredShown,
                                    isAccessoriesButtonAvailable: isAppropriateToShowAccessories(forMainContentSize: mainContentSize))
                    }
                    .preference(key: MainContentSizeKey.self, value: geo.size)
                    .navigationTitle(toolbarTitle)
            }
        }
        .onPreferenceChange(MainContentSizeKey.self) { new in
            mainContentSize = new
        }
        .background(background)
        .contextMenu { mainMenuContent }
    }
    #endif
    
    #if os(iOS)
    private var bodyContent: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geo in
                    VideoDisplayAndShownAccessories(areAccessoriesShown: areAccessoriesShown, gameScreenScale: gameScreenScale)
                        .preference(key: MainContentSizeKey.self, value: geo.size)
                }
                .onPreferenceChange(MainContentSizeKey.self) { new in
                    mainContentSize = new
                }
                
                OnscreenControllerWithHandling()
                    .frame(maxWidth: .infinity)
                    .opacity(isOnscreenControllerShown ? onscreenControllerPreferredOpacity : 0)
                    .animation(.linear(duration: 0.5), value: isOnscreenControllerShown)
            }
            .background(background)
            .toolbar {
                MainToolbar(isWelcomeViewShown: $viewModel.isWelcomeViewShown,
                            areAccessoriesPreferredShown: $areAccessoriesPreferredShown,
                            isAccessoriesButtonAvailable: isAppropriateToShowAccessories(forMainContentSize: mainContentSize))
            }
            .navigationTitle(toolbarTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
        .statusBar(hidden: !areAccessoriesShown)
        .animation(.default, value: areAccessoriesShown)
    }
    #endif
    
    private var toolbarTitle: String {
        #if os(macOS)
        if let loadedROMTitle = viewModel.loadedROMTitle {
            return "Blackbox  |  \(loadedROMTitle)"
        }
        return "Blackbox"
        #else
        ""
        #endif
    }
    
    // MARK: Settings
    
    private var settings: some View {
        SettingsView(isOnscreenControllerPreferredAlwaysShown: $isOnscreenControllerPreferredAlwaysShown,
                     onscreenControllerPreferredOpacity: $onscreenControllerPreferredOpacity)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Settings")
        .toolbar { settingsToolbarContent }
    }
    
    @ToolbarContentBuilder
    private var settingsToolbarContent: some ToolbarContent {
        #if os(macOS)
        let placement = ToolbarItemPlacement.automatic
        #elseif os(iOS)
        let placement = ToolbarItemPlacement.navigationBarTrailing
        #endif
        ToolbarItem(placement: placement) {
            Button {
                viewModel.isSettingsViewShown = false
            } label: {
                Text("Done")
            }
        }
    }
    
    // MARK: Misc
    
    private var isPhone: Bool {
        #if os(macOS)
        false
        #else
        UIDevice.current.userInterfaceIdiom == .phone
        #endif
    }
    
    private var areAccessoriesShown: Bool {
        isAppropriateToShowAccessories(forMainContentSize: mainContentSize) &&
        (areAccessoriesPreferredShown || Self.isInPreviewMode)
    }
    
    #if os(iOS)
    private var isOnscreenControllerShown: Bool {
        guard !Self.isInPreviewMode else { return true }
        return shouldOnscreenControllerBeShown || isOnscreenControllerPreferredAlwaysShown
    }
    #endif

    /// Returns a `Bool` indicating whether the app’s main area size is too narrow to show accessory columns on either side of the emulated video display.
    private func isAppropriateToShowAccessories(forMainContentSize size: CGSize) -> Bool {
        guard size != .zero else {
            // If we're getting called with size zero, it's because the rest of the app's layout hasn't been set yet. Returning `true` here in that case prevents a visual issue on app launch where the accessories slide in rather than just being there from the beginning.
            return true
        }
        guard size.width >= 500 else {
            // If we're smaller than 500 points wide, we're too narrow
            return false
        }
        let isLandscape = size.width > size.height
        return !isPhone || isLandscape
    }
    
    private func animateBounce() {

        #if(swift(<5.9))

        // SDKs before Xcode 15 don't have `Animation.spring(duration:)` so let's just skip the animation altogether
        viewModel.isAnimatedBounceNeeded = false
        
        #else
        
        guard !reduceMotion else { return }
        
        // TODO: If we don't add this hacky dispatch, the bounce doesn't show. Why?
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let duration = 0.5
            let changePercent = 3.0

            // TODO: There's probably a better way to do this (see new method from WWDC 2023: withAnimation(_:completionCriteria:body:completion:)
                        
            withAnimation(.spring(duration: duration / 3.0).repeatCount(2, autoreverses: true)) {
                gameScreenScale = 1 + changePercent / 100
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration * 2.0/3.0) {
                withAnimation(.spring(duration: duration / 3.0)/*.repeatCount(2, autoreverses: true)*/) {
                    gameScreenScale = 1
                    viewModel.isAnimatedBounceNeeded = false
                }
            }
        }
        #endif
    }
    
    private func string(for details: ViewModel.ErrorContent.Details) -> String {
        switch details {
        case .errorOpeningCartridge(let cartridgeLoaderError):
            switch cartridgeLoaderError {
            case .couldNotLoadROMURL:
                return "Could not load data from file."
            case .couldNotParseAsINESFile:
                return "File could not be parsed as an iNES file."
            case .mapperNotSupported(let mapperID):
                return """
                    The mapper chip (mapper ID: \(mapperID)) used by this ROM is not yet supported by Blackbox.

                    Mapper chips (“mappers”) were enhancement chips included in NES cartridges to enable extra functionality.

                    Blackbox currently only supports mappers from the earliest NES releases such as the “black box” games released in North America in 1985 or soon after.
                    """
            }
        }
    }
    
    private enum MainContentSizeKey: PreferenceKey {
        static var defaultValue: CGSize = .zero
        static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
            value = nextValue()
        }
    }
}

// MARK: - Previews

struct MainView_Previews: PreviewProvider {
        
    static var previews: some View {
        #if os(iOS)
        
        mainView()
            .previewDisplayName("iPhone SE (3rd generation) - Portrait")
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
            .previewInterfaceOrientation(.portrait)

        mainView()
            .previewDisplayName("iPhone SE (3rd generation) - Landscape")
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
            .previewInterfaceOrientation(.landscapeLeft)

        mainView()
            .previewDisplayName("iPhone 14 - Landscape")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewInterfaceOrientation(.landscapeLeft)

        mainView()
            .previewDisplayName("iPhone 14 Pro Max - Portrait")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
            .previewInterfaceOrientation(.portrait)

        mainView()
            .previewDisplayName("iPhone 14 Pro Max - Landscape")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
            .previewInterfaceOrientation(.landscapeLeft)

            .previewDisplayName("iPhone 14 Pro Max - Landscape - No ROM Loaded")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
            .previewInterfaceOrientation(.landscapeLeft)

        mainView()
            .previewDisplayName("iPad Pro (11-inch) (4th generation) - Portrait")
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))

        mainView()
            .previewDisplayName("iPad Pro (11-inch) (4th generation) - Landscape")
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
            .previewInterfaceOrientation(.landscapeLeft)

        mainView()
            .previewDisplayName("iPad Pro (12.9-inch) (6th generation) - Portrait")
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
            .previewInterfaceOrientation(.portrait)

        mainView()
            .previewDisplayName("iPad Pro (12.9-inch) (6th generation) - Landscape")
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
            .previewInterfaceOrientation(.landscapeLeft)

        mainView(accessoriesViewModel: AccessoriesViewModel())
            .previewDisplayName("iPad Pro (12.9-inch) (6th generation) - Landscape - No ROM Loaded")
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
            .previewInterfaceOrientation(.landscapeLeft)

        #elseif os(macOS)

        mainView()
            .previewDisplayName("Mac")
            
        mainView(accessoriesViewModel: AccessoriesViewModel())
            .previewDisplayName("Mac - No ROM Loaded")
        
        mainView()
            .previewDisplayName("Mac - 1024×768")
            .previewLayout(.fixed(width: 1024, height: 768))

        #endif
    }
    
    private static func mainView(
        viewModel: ViewModel = .init(),
        videoDisplayViewModel: VideoDisplayViewModel = Self.videoDisplayViewModel,
        accessoriesViewModel: AccessoriesViewModel = Self.accessoriesViewModel
    ) -> some View {
        MainView()
            .environmentObject(viewModel)
            .environmentObject(videoDisplayViewModel)
            .environmentObject(accessoriesViewModel)
    }
}
