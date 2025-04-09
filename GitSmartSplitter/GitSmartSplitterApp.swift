//
//  GitSmartSplitterApp.swift
//  GitSmartSplitter
//
//  Created by Lukas Mauffré on 08/04/2025.
//

import SwiftUI

@main
struct GitSmartSplitterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Vérifier les mises à jour…") {
                    UpdateChecker.checkForUpdates()
                }
            }
        }
    }
}
