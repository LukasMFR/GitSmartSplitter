//
//  SegmentButtonView.swift
//  GitSmartSplitter
//
//  Created by Lukas Mauffré on 08/04/2025.
//

import SwiftUI
import Neumorphic

struct SegmentButtonView: View {
    let segmentIndex: Int
    let totalSegments: Int
    let segmentText: String
    @State private var copied: Bool = false
    
    var body: some View {
        Button(action: copyAction) {
            Text(copied ? "Copié !" : segmentLabel(index: segmentIndex, total: totalSegments))
                .fontWeight(.medium)
                .foregroundColor(AppStyle.textColor)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .softButtonStyle(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius),
            padding: 12,
            mainColor: AppStyle.mainColor,
            textColor: AppStyle.textColor,
            darkShadowColor: AppStyle.darkShadow,
            lightShadowColor: AppStyle.lightShadow,
            pressedEffect: .flat
        )
        .animation(.easeInOut(duration: 0.25), value: copied)
    }
    
    private func copyAction() {
        let fullSegment = addHeaderToSegment(segment: segmentText, index: segmentIndex, total: totalSegments)
        copySegmentToClipboard(fullSegment)
        withAnimation {
            copied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                copied = false
            }
        }
    }
    
    func segmentLabel(index: Int, total: Int) -> String {
        if index == total - 1 {
            return String(format: NSLocalizedString("SegmentLabelFinal", comment: "Label for final segment, e.g., 'Part %d of %d - Final'"), index + 1, total)
        } else {
            return String(format: NSLocalizedString("SegmentLabel", comment: "Label for segment, e.g., 'Part %d of %d'"), index + 1, total)
        }
    }
}

#Preview {
    SegmentButtonView(segmentIndex: 2, totalSegments: 3, segmentText: "hello")
}
