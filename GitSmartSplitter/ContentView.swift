//
//  ContentView.swift
//  GitSmartSplitter
//
//  Created by Lukas Mauffré on 08/04/2025.
//

import SwiftUI
import AppKit

// MARK: - Modes de segmentation
enum SplitMode: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case maxLength = "Taille maximale par segment"
    case numberOfSegments = "Nombre de segments"
}

// MARK: - Vue principale
struct ContentView: View {
    @State private var inputText: String = ""
    @State private var selectedMode: SplitMode = .maxLength
    @State private var maxSegmentLength: Int = 1000
    @State private var numberOfSegments: Int = 5
    @State private var segments: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("GitSmartSplitter")
                .font(.title)
            
            Text("Collez ici le texte complet (copie depuis uithub.com) :")
            TextEditor(text: $inputText)
                .border(Color.gray)
                .frame(height: 200)
            
            // Sélection du mode de segmentation
            Picker("Mode de segmentation", selection: $selectedMode) {
                ForEach(SplitMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Paramètre spécifique en fonction du mode choisi
            if selectedMode == .maxLength {
                HStack {
                    Text("Taille max par segment (en caractères) :")
                    TextField("1000", value: $maxSegmentLength, formatter: NumberFormatter())
                        .frame(width: 100)
                }
            } else {
                HStack {
                    Text("Nombre de segments désiré :")
                    TextField("5", value: $numberOfSegments, formatter: NumberFormatter())
                        .frame(width: 100)
                }
            }
            
            Button("Segmenter le texte") {
                if selectedMode == .maxLength {
                    segments = splitTextSmart(inputText, maxSegmentLength: maxSegmentLength)
                } else {
                    segments = splitTextBySegmentCount(inputText, numberOfSegments: numberOfSegments)
                }
            }
            .buttonStyle(BorderedButtonStyle())
            .padding(.vertical)
            
            if !segments.isEmpty {
                Text("Segments :")
                    .font(.headline)
                // Grille scrollable
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 16
                    ) {
                        ForEach(segments.indices, id: \.self) { index in
                            SegmentButtonView(
                                segmentIndex: index,
                                totalSegments: segments.count,
                                segmentText: segments[index]
                            )
                        }
                    }
                    .padding(.vertical)
                }
                // Hauteur maximale de la grille pour éviter de grossir la fenêtre
                .frame(maxHeight: 300)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Vue pour chaque bouton de segment
struct SegmentButtonView: View {
    let segmentIndex: Int
    let totalSegments: Int
    let segmentText: String
    @State private var copied: Bool = false
    
    var body: some View {
        Button(action: {
            let fullSegment = addHeaderToSegment(segment: segmentText,
                                                 index: segmentIndex,
                                                 total: totalSegments)
            copySegmentToClipboard(fullSegment)
            // Animation pour indiquer la copie
            withAnimation {
                copied = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    copied = false
                }
            }
        }) {
            Text(copied ?
                 "Copié!" :
                    "Partie \(segmentIndex + 1) sur \(totalSegments)" + (segmentIndex == totalSegments - 1 ? " - Finale" : ""))
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(BorderedButtonStyle())
    }
}

// MARK: - Fonctions de segmentation

/// Segmente le texte en respectant une taille maximale pour chaque segment et en utilisant la ligne de tirets comme point de découpe.
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

/// Segmente le texte pour obtenir exactement le nombre de segments souhaité.
/// La découpe se fait d'abord en se basant sur le séparateur (la ligne de tirets)
/// et, si besoin, en forçant le découpage du segment le plus long.
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
    
    // Si le nombre de segments est inférieur au désiré, on découpe le segment le plus long
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
    
    // Si l'on obtient trop de segments, fusionner les derniers avec le précédent
    while segments.count > numberOfSegments {
        let lastSegment = segments.removeLast()
        segments[segments.count - 1] += "\n" + lastSegment
    }
    
    return segments
}

/// Ajoute un en-tête à un segment pour indiquer sa position (et le tag "Finale" pour le dernier segment).
func addHeaderToSegment(segment: String, index: Int, total: Int) -> String {
    let header = (index == total - 1)
    ? "*** Partie \(index + 1) sur \(total) - Finale ***\n\n"
    : "*** Partie \(index + 1) sur \(total) ***\n\n"
    return header + segment
}

// MARK: - Copie dans le presse-papier

/// Copie le texte du segment dans le presse-papier.
func copySegmentToClipboard(_ segment: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(segment, forType: .string)
}

#Preview {
    ContentView()
}
