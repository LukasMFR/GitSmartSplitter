//
//  ContentView.swift
//  GitSmartSplitter
//
//  Created by Lukas Mauffré on 08/04/2025.
//

import SwiftUI
import AppKit
import Neumorphic

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var selectedMode: SplitMode = .numberOfSegments
    @State private var maxSegmentLength: Int = 1000
    @State private var numberOfSegments: Int = 5
    @State private var segments: [String] = []
    
    init() {
        AppStyle.autoMode() // Active le thème clair/sombre auto dès l’ouverture
    }
    
    var body: some View {
        ZStack {
            AppStyle.mainColor.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: AppStyle.padding) {
                    
                    AppStyle.styledTitle("GitSmartSplitter")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Collez ici le texte complet :")
                                .foregroundColor(AppStyle.textColor)
                            
                            AppStyle.primaryButton("Coller depuis le presse-papier") {
                                if let clipboardText = NSPasteboard.general.string(forType: .string) {
                                    inputText = clipboardText
                                }
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Text("Copie depuis :")
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                if let url = URL(string: "https://uithub.com") {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text("uithub.com")
                                        .bold()
                                        .underline()
                                    Image(systemName: "link")
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(.blue)
                            .onHover { hovering in
                                if hovering { NSCursor.pointingHand.set() }
                            }
                            .help("Ouvrir uithub.com")
                        }
                        .font(.subheadline)
                    }
                    
                    TextEditor(text: $inputText)
                        .frame(height: 200)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppStyle.mainColor)
                                .softInnerShadow(
                                    RoundedRectangle(cornerRadius: 16),
                                    darkShadow: AppStyle.darkShadow,
                                    lightShadow: AppStyle.lightShadow,
                                    spread: 0.05,
                                    radius: 2
                                )
                        )
                        .foregroundColor(AppStyle.textColor)
                    
                    Text("Nombre total de lignes : \(inputText.components(separatedBy: "\n").count)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Picker("Mode de segmentation", selection: $selectedMode) {
                        ForEach(SplitMode.allCases) { mode in
                            Text(mode == .numberOfSegments ? "splitMode.numberOfSegments" : "splitMode.maxLength")
                                .tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if selectedMode == .maxLength {
                        HStack {
                            Text("Taille max par segment :")
                            TextField("1000", value: $maxSegmentLength, formatter: NumberFormatter())
                                .frame(width: 80)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    } else {
                        HStack {
                            Text("Nombre de segments désiré :")
                            TextField("5", value: $numberOfSegments, formatter: NumberFormatter())
                                .frame(width: 80)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        HStack(spacing: 8) {
                            ForEach([2, 3, 4, 5, 6, 7], id: \.self) { number in
                                Button(action: {
                                    numberOfSegments = number
                                }) {
                                    Text("\(number)")
                                        .frame(width: 30, height: 30)
                                }
                                .softButtonStyle(Circle(), pressedEffect: .flat)
                            }
                        }
                    }
                    
                    AppStyle.primaryButton("Segmenter le texte") {
                        if selectedMode == .maxLength {
                            segments = splitTextSmart(inputText, maxSegmentLength: maxSegmentLength)
                        } else {
                            segments = splitTextBySegmentCount(inputText, numberOfSegments: numberOfSegments)
                        }
                    }
                    .padding(.top)
                    
                    if !segments.isEmpty {
                        Text("Segments :")
                            .font(.headline)
                            .foregroundColor(AppStyle.textColor)
                            .padding(.bottom, 4)
                        
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
                            .padding(.top, 12) // 👈 Ajouté pour éviter le rognage en haut
                            .padding(.horizontal, 8)
                            .padding(.bottom)
                            .background(Color.clear)
                        }
                        .frame(maxHeight: 300)
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(minWidth: 600, minHeight: 700)
            }
        }
    }
}

#Preview("en") {
    ContentView()
        .environment(\.locale, .init(identifier: "en"))
}
