//
//  AppStyle.swift
//  GitSmartSplitter
//
//  Created by Lukas Mauffré on 09/04/2025.
//

import SwiftUI
import Neumorphic

struct AppStyle {
    
    // MARK: - Couleurs
    static let mainColor = Color.Neumorphic.main
    static let darkShadow = Color.Neumorphic.darkShadow
    static let lightShadow = Color.Neumorphic.lightShadow
    static let textColor = Color.primary
    
    // MARK: - Coins et padding
    static let cornerRadius: CGFloat = 20
    static let padding: CGFloat = 16
    
    // MARK: - Conteneur stylé avec Neumorphism
    static var styledContainer: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(mainColor)
            .softInnerShadow(
                RoundedRectangle(cornerRadius: cornerRadius),
                darkShadow: darkShadow,
                lightShadow: lightShadow,
                spread: 0.1,
                radius: 2
            )
    }
    
    // MARK: - Style de bouton principal
    static func primaryButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
        .softButtonStyle(
            RoundedRectangle(cornerRadius: cornerRadius),
            padding: 0,
            mainColor: mainColor,
            textColor: textColor,
            darkShadowColor: darkShadow,
            lightShadowColor: lightShadow,
            pressedEffect: .flat
        )
    }
    
    // MARK: - Titre stylé
    static func styledTitle(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(textColor)
            .padding(.bottom, 8)
    }
    
    // MARK: - TextField stylé
    static func styledTextField(text: Binding<String>, placeholder: String = "") -> some View {
        TextField(placeholder, text: text)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(mainColor)
                    .softInnerShadow(
                        RoundedRectangle(cornerRadius: 30),
                        darkShadow: darkShadow,
                        lightShadow: lightShadow,
                        spread: 0.05,
                        radius: 2
                    )
            )
            .foregroundColor(textColor)
    }
    
    // MARK: - Forcer le mode (optionnel, à activer manuellement si besoin)
    static func forceDarkMode() {
        Color.Neumorphic.colorSchemeType = .dark
    }
    
    static func forceLightMode() {
        Color.Neumorphic.colorSchemeType = .light
    }
    
    static func autoMode() {
        Color.Neumorphic.colorSchemeType = .auto
    }
}
