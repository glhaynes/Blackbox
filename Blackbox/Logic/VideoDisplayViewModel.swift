//
//  VideoDisplayViewModel.swift
//  Blackbox
//
//  Created by Grady Haynes on 6/26/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import Foundation
import CoreGraphics
import Combine

final class VideoDisplayViewModel: ObservableObject {
    @Published var image: CGImage?
    
    init(image: CGImage? = nil) {
        self.image = image
    }
}
