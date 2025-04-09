//
//  UpdateChecker.swift
//  GitSmartSplitter
//
//  Created by Lukas Mauffré on 09/04/2025.
//

import SwiftUI

class UpdateChecker {
    static func checkForUpdates() {
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        
        // Remplace ici par ton propre repo
        let repo = "LukasMFR/GitSmartSplitter"
        let url = URL(string: "https://api.github.com/repos/\(repo)/tags")!
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                if let tags = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                   let latestTag = tags.first?["name"] as? String {
                    
                    let latestVersion = latestTag.replacingOccurrences(of: "v", with: "")
                    
                    if latestVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = String(localized: "update_available_title")
                            alert.informativeText = String(localized: "update_available_body \(latestVersion) \(currentVersion)")
                            alert.alertStyle = .informational
                            alert.addButton(withTitle: String(localized: "download_button"))
                            alert.addButton(withTitle: String(localized: "later_button"))
                            
                            if alert.runModal() == .alertFirstButtonReturn {
                                if let url = URL(string: "https://github.com/LukasMFR/GitSmartSplitter/releases") {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = String(localized: "update_latest_title")
                            alert.informativeText = String(localized: "update_latest_body")
                            alert.alertStyle = .informational
                            alert.addButton(withTitle: String(localized: "ok_button"))
                            alert.runModal()
                        }
                    }
                }
            } catch {
                print("Erreur JSON : \(error)")
            }
        }
        
        task.resume()
    }
}
