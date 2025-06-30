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
    Button {
      onTap()
    } label: {

      // iOS 15+
      if #available(iOS 15.0, *) {
        Image(systemName: "xmark.circle.fill")
          .font(.largeTitle)
          //.foregroundColor(W3WCoreColor(hex: 0x4B7189).suColor)
          //.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
          .foregroundStyle(.thinMaterial)
          //.foregroundStyle(.orange, .green, .yellow)
          .padding(.trailing)

      // iOS 14-
      } else {
        Image(systemName: "xmark.circle.fill")
          .font(.largeTitle)
          .foregroundColor(W3WCoreColor(hex: 0x4B7189).suColor)
          //.background(W3WColor.background.current.suColor)
          .padding(.trailing)
      }
    }
  }
}


#Preview {
  W3WCloseButtonX() { }
}
