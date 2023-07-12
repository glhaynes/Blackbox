//
//  VideoRefresher.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/26/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation
import Combine

final class VideoRefresher {
    private var subscriptions: Set<AnyCancellable> = []
    
    func startVideoRefresh(_ onFrame: @escaping () -> Void) {
        assert(subscriptions.isEmpty)
        // TODO: We used to use `DisplayLink` (open source) package to drive refresh. That led to slowness on some devices; this seems like an improvement, but I don't love it.
        Timer.publish(every: 1.0/60.0, on: .main, in: .common).autoconnect().sink { _ in
            onFrame()
        }
        .store(in: &subscriptions)
    }
}
