//
//  VideoDisplay.swift
//  Blackbox
//
//  Created by Grady Haynes on 5/23/23.
//  Copyright © 2023 Grady Haynes. All rights reserved.
//

import SwiftUI

struct VideoDisplay: View {
    
    let cornerRadius: CGFloat
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var videoDisplayViewModel: VideoDisplayViewModel

    var body: some View {
        Group {
            if let videoImage = videoDisplayViewModel.image {
                Image(videoImage, scale: 1, label: Text("videoImage"))
                    .resizable()
            } else {
                noScreenshot
            }
        }
        .cornerRadius(cornerRadius)
    }
    
    private var noScreenshot: some View {
        GeometryReader { geo in
            Color.clear
                .background {
                    let maxSide = max(geo.size.width, geo.size.height)
                    RadialGradient(stops: gradientStops,
                                   center: .center,
                                   startRadius: 0,
                                   endRadius: maxSide)
                }
        }
    }
    
    private var gradientStops: [Gradient.Stop] {
        switch colorScheme {
        case .dark:
            return [.init(color: .init(white: 0.175), location: 0), .init(color: .init(white: 0.03), location: 1)]
        case .light:
            return [.init(color: .init(white: 0.35), location: 0), .init(color: .init(white: 0.08), location: 1)]
        @unknown default:
            return []
        }
    }
}

struct VideoDisplay_Previews: PreviewProvider {
    static var previews: some View {
        VideoDisplay(cornerRadius: 10.0)
            .environmentObject(VideoDisplayViewModel())
    }
}
