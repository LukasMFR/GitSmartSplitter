//
//  ContentView.swift
//  GitSmartSplitter
//
//  Created by Lukas Mauffré on 08/04/2025.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State private var inputText: String = ""
    // Mode par défaut : Nombre de segments
    @State private var selectedMode: SplitMode = .numberOfSegments
    @State private var maxSegmentLength: Int = 1000
    @State private var numberOfSegments: Int = 5
    @State private var segments: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("GitSmartSplitter")
                .font(.title)
            
            // Zone de saisie avec bouton de collage depuis le presse-papier
            HStack {
                Text("Collez ici le texte complet (copie depuis uithub.com) :")
                Button("Coller depuis le presse-papier") {
                    if let clipboardText = NSPasteboard.general.string(forType: .string) {
                        inputText = clipboardText
                    }
                }
                .buttonStyle(BorderedButtonStyle())
            }
            
            TextEditor(text: $inputText)
                .border(Color.gray)
                .frame(height: 200)
            
            // Affichage du nombre total de lignes sous la zone d'édition.
            Text("Nombre total de lignes : \(inputText.components(separatedBy: "\n").count)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Picker pour choisir le mode de segmentation
            Picker("Mode de segmentation", selection: $selectedMode) {
                ForEach(SplitMode.allCases) { mode in
                    // Utilisation de littéraux pour les clés de localisation, afin qu'ils soient extraits automatiquement par Xcode.
                    if mode == .numberOfSegments {
                        Text("splitMode.numberOfSegments").tag(mode)
                    } else {
                        Text("splitMode.maxLength").tag(mode)
                    }
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Affichage du paramètre en fonction du mode sélectionné
            if selectedMode == .maxLength {
                HStack {
                    Text("Taille max par segment (en caractères) :")
                    TextField("1000", value: $maxSegmentLength, formatter: NumberFormatter())
                        .frame(width: 100)
                }
            } else {
                // Mode "Nombre de segments"
                HStack {
                    Text("Nombre de segments désiré :")
                    TextField("5", value: $numberOfSegments, formatter: NumberFormatter())
                        .frame(width: 100)
                }
                // Boutons préréglés pour un choix rapide
                HStack(spacing: 8) {
                    ForEach([2, 3, 4, 5, 6, 7], id: \.self) { number in
                        Button(action: {
                            numberOfSegments = number
                        }) {
                            Text("\(number)")
                                .frame(width: 30, height: 30)
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
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
                // Grille scrollable pour afficher les boutons des segments
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
                .frame(maxHeight: 300)
            }
            
            Spacer()
        }
        .padding()
        // Taille minimale de la fenêtre : largeur à 600 points et hauteur à 700 points
        .frame(minWidth: 600, minHeight: 700)
    }
}

#Preview("en") {
    ContentView()
        .environment(\.locale, .init(identifier: "en"))
}
