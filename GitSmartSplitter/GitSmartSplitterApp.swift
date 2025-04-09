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
        
        // ✅ Ce bloc gère la fenêtre "Paramètres…" automatiquement
        Settings {
            SettingsView()
        }
        
        // ✅ Commandes supplémentaires (sans redéclarer "Paramètres…")
        .commands {
            CommandGroup(after: .appInfo) {
                Divider()
                Button("Vérifier les mises à jour…") {
                    UpdateChecker.checkForUpdates()
                }
            }
        }
    }
}
