//
//  SplitMode.swift
//  GitSmartSplitter
//
//  Created by Lukas Mauffré on 08/04/2025.
//

import SwiftUI

// MARK: - Modes de segmentation (ordre inversé)
// On utilise une énumération à raw value de type String avec des clés explicites pour la localisation.
// Ces clés (par exemple, "splitMode.numberOfSegments") seront extraites automatiquement par Xcode.
enum SplitMode: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case numberOfSegments = "splitMode.numberOfSegments"
    case maxLength = "splitMode.maxLength"
    
    var displayName: LocalizedStringKey {
        // Retourne la chaîne localisée à partir de la clé.
        LocalizedStringKey(self.rawValue)
    }
}
