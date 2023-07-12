//
//  RecentsManager.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/14/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import os.log
import Foundation

final class RecentsManager {
    
    @Published var recentLoadableROMs: [LoadableROM] = []
    
    private let logger: Logger?
    
    private var recentsList: RecentsList<LoadableROM> {
        didSet {
            handleRecentsListMutation()
        }
    }
    
    init(logger: Logger?) {
        self.logger = logger
        recentsList = IO.loadRecentsList()
        handleRecentsListMutation()
    }
    
    func addRecentForSampleROM() {
        recentsList.add(.sampleROM)
    }
        
    func addRecent(for url: URL) {
        if let loadableROM = IO.loadableROM(for: url) {
            recentsList.add(loadableROM)
        } else {
            // TODO: How do we feel about leaking url here?
            logger?.log(level: .error, "Unexpected problem when getting bookmark data for URL \(url)")
        }
    }
    
    private func handleRecentsListMutation() {
        IO.save(recentsList)
        recentLoadableROMs = recentsList.elements
    }
    
    private enum IO {
        private static let userDefaultsKey = "recentLoadableROMs"
        
        static func save(_ recentsList: RecentsList<LoadableROM>) {
            guard let json = try? JSONEncoder().encode(recentsList.elements) else { return }
            UserDefaults.standard.setValue(json, forKey: Self.userDefaultsKey)
        }

        static func loadRecentsList() -> RecentsList<LoadableROM> {
            guard let userDefaultsData = UserDefaults.standard.data(forKey: Self.userDefaultsKey),
                  let loadableROMs: [LoadableROM] = try? JSONDecoder().decode([LoadableROM].self, from: userDefaultsData) else {
                return RecentsList(elements: [], maxCount: 5)
            }
            return RecentsList(elements: loadableROMs, maxCount: 5)
        }
        
        static func loadableROM(for url: URL) -> LoadableROM? {
            #if os(macOS)
            let options: URL.BookmarkCreationOptions = [.withSecurityScope, .securityScopeAllowOnlyReadAccess]
            #else
            let options: URL.BookmarkCreationOptions = []
            #endif
            
            let isSandboxExtended = url.startAccessingSecurityScopedResource()
            defer {
                if isSandboxExtended {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            if let bookmark = try? url.bookmarkData(options: options) {
                return LoadableROM.file(bookmarkData: bookmark, url: url)
            } else {
                return nil
            }
        }
    }
}
