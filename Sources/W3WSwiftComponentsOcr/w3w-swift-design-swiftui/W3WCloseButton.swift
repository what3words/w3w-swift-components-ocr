//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/06/2025.
//

import SwiftUI
import W3WSwiftThemes


struct W3WCloseButtonX: View {
  
  var onTap: () -> ()
  
  var body: some View {
    Button(action: onTap) {
      Image(systemName: "xmark")
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(W3WCoreColor.white.suColor)
        .frame(width: 34, height: 34)
        .background(
          W3WCoreColor(hex: 0x7F7F7F).suColor
            .background(W3WCoreColor(hex: 0xC2C2C2).suColor.opacity(0.5))
            .opacity(0.2)
        )
        .clipShape(.circle)
    }
  }
}


#Preview {
  W3WCloseButtonX() { }
}
