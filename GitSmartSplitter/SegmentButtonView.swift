//
//  SegmentButtonView.swift
//  GitSmartSplitter
//
//  Created by Lukas Mauffré on 08/04/2025.
//

import SwiftUI

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
            withAnimation {
                copied = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    copied = false
                }
            }
        }) {
            if copied {
                Text("Copié !")
                    .frame(maxWidth: .infinity, minHeight: 44)
            } else {
                Text(segmentLabel(index: segmentIndex, total: totalSegments))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        }
        .buttonStyle(BorderedButtonStyle())
    }
    
    // Cette fonction utilise NSLocalizedString avec des clés fixes pour générer le label.
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
