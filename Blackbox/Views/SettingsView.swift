//
//  SettingsView.swift
//  Blackbox
//
//  Created by Grady Haynes on 11/8/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var isOnscreenControllerPreferredAlwaysShown: Bool
    @Binding var onscreenControllerPreferredOpacity: Double
    
    var body: some View {
        Form {
            Section {
                Slider(value: $onscreenControllerPreferredOpacity) {
                    Text("Onscreen Controller Transparency")
                } minimumValueLabel: {
                    Image(systemName: "circle.dotted")
                        .accessibilityLabel("Transparent")
                } maximumValueLabel: {
                    Image(systemName: "circle")
                        .accessibilityLabel("Opaque")
                }

                Toggle("Always Show", isOn: $isOnscreenControllerPreferredAlwaysShown)
            } header: {
                Text("Onscreen Controller Transparency")
            } footer: {
                Text(onscreenControllerFooterText)
            }

            Section {
                AboutView()
            } header: {
                Text("About")
            }
        }
    }
    
    private var onscreenControllerFooterText: String {
        if isOnscreenControllerPreferredAlwaysShown {
            return "Onscreen controller will always be shown."
        } else {
            return "Onscreen controller will be hidden while a physical game controller or keyboard is connected."
            // TODO: "hardware" or "physical" or ...?
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isOnscreenControllerPreferredAlwaysShown: .constant(false),
                     onscreenControllerPreferredOpacity: .constant(0.25))
        .previewLayout(.fixed(width: 500, height: 800))
    }
}
