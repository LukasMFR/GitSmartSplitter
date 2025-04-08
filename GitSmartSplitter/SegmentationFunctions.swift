//
//  SegmentationFunctions.swift
//  GitSmartSplitter
//
//  Created by Lukas Mauffré on 08/04/2025.
//

import Foundation
import AppKit

/// Segmente le texte en respectant une taille maximale par segment,
/// en privilégiant les coupes sur la ligne de tirets.
func splitTextSmart(_ text: String, maxSegmentLength: Int) -> [String] {
    let separatorLine = "--------------------------------------------------------------------------------"
    var segments: [String] = []
    var currentSegment = ""
    
    let lines = text.components(separatedBy: "\n")
    for line in lines {
        if currentSegment.count + line.count + 1 > maxSegmentLength && !currentSegment.isEmpty {
            if line.trimmingCharacters(in: .whitespaces) == separatorLine {
                currentSegment += line + "\n"
                segments.append(currentSegment)
                currentSegment = ""
            } else {
                segments.append(currentSegment)
                currentSegment = line + "\n"
            }
        } else {
            currentSegment += line + "\n"
        }
    }
    if !currentSegment.isEmpty {
        segments.append(currentSegment)
    }
    return segments
}

/// Segmente le texte pour obtenir exactement le nombre de segments demandé.
/// La découpe est d'abord basée sur le séparateur (la ligne de tirets) et, si nécessaire,
/// le segment le plus long est scindé pour atteindre le nombre désiré.
func splitTextBySegmentCount(_ text: String, numberOfSegments: Int) -> [String] {
    let separatorLine = "--------------------------------------------------------------------------------"
    let totalLength = text.count
    let approximateSegmentLength = totalLength / max(numberOfSegments, 1)
    var segments: [String] = []
    var currentSegment = ""
    var currentLength = 0
    let lines = text.components(separatedBy: "\n")
    
    for line in lines {
        let lineWithNewline = line + "\n"
        currentSegment += lineWithNewline
        currentLength += lineWithNewline.count
        
        if segments.count < numberOfSegments - 1 {
            if currentLength >= approximateSegmentLength &&
                line.trimmingCharacters(in: .whitespaces) == separatorLine {
                segments.append(currentSegment)
                currentSegment = ""
                currentLength = 0
            }
        }
    }
    if !currentSegment.isEmpty {
        segments.append(currentSegment)
    }
    
    // Si le nombre de segments est inférieur au désiré, découper le segment le plus long.
    while segments.count < numberOfSegments {
        if let maxIndex = segments.enumerated().max(by: { $0.element.count < $1.element.count })?.offset {
            let segmentToSplit = segments.remove(at: maxIndex)
            let midIndex = segmentToSplit.index(segmentToSplit.startIndex, offsetBy: segmentToSplit.count / 2)
            if let newlineIndex = segmentToSplit[..<midIndex].lastIndex(of: "\n") {
                let part1 = String(segmentToSplit[..<newlineIndex])
                let part2 = String(segmentToSplit[newlineIndex...])
                segments.insert(part1, at: maxIndex)
                segments.insert(part2, at: maxIndex + 1)
            } else {
                let mid = segmentToSplit.index(segmentToSplit.startIndex, offsetBy: segmentToSplit.count / 2)
                let part1 = String(segmentToSplit[..<mid])
                let part2 = String(segmentToSplit[mid...])
                segments.insert(part1, at: maxIndex)
                segments.insert(part2, at: maxIndex + 1)
            }
        } else {
            break
        }
    }
    
    // Si l'on obtient trop de segments, fusionner les derniers avec le précédent.
    while segments.count > numberOfSegments {
        let lastSegment = segments.removeLast()
        segments[segments.count - 1] += "\n" + lastSegment
    }
    
    return segments
}

/// Ajoute un en-tête à un segment pour indiquer sa position.
/// Les clés "Header" et "FinalHeader" ne contiennent pas les retours à la ligne,
/// qui sont ajoutés ici dans le code pour séparer l'en-tête du segment.
func addHeaderToSegment(segment: String, index: Int, total: Int) -> String {
    let header: String
    if index == total - 1 {
        header = String(
            format: NSLocalizedString("FinalHeader", comment: "Header for final segment, e.g., '*** Part %d of %d - Final ***'"),
            index + 1, total
        )
    } else {
        header = String(
            format: NSLocalizedString("Header", comment: "Header for segment, e.g., '*** Part %d of %d ***'"),
            index + 1, total
        )
    }
    return header + "\n\n" + segment
}

/// Copie le segment dans le presse-papier.
func copySegmentToClipboard(_ segment: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(segment, forType: .string)
}
