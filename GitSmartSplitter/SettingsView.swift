//
//  SettingsView.swift
//  GitSmartSplitter
//
//  Created by Lukas Mauffré on 09/04/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("includeDefaultPrompt") private var includeDefaultPrompt = true
    
    var body: some View {
        Form {
            Section(header: Text("cutting_preferences")) {
                Toggle(isOn: $includeDefaultPrompt) {
                    Text("default_prompt_toggle")
                }
            }
        }
        .padding()
        .frame(width: 400)
    }
}

#Preview {
    SettingsView()
}
