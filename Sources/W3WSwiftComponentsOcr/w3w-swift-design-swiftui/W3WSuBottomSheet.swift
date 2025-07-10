//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 02/05/2025.
//


import SwiftUI
import W3WSwiftThemes

public struct W3WSuBottomSheet<Content: View>: View {
  
  public let scheme: W3WScheme?
  
  @State var height: CGFloat
  
  let detents: W3WDetents
  
  @ViewBuilder let content: Content
  
  
  public var body: some View {
    VStack {
      W3WCoreColor(hex: 0x3D3D3D).suColor
        .background(W3WCoreColor(hex: 0x7F7F7F).suColor.opacity(0.4))
        .opacity(0.5)
        .frame(width: 36, height: 5)
        .clipShape(.capsule)
        .padding(W3WPadding.medium.value)
      
      content
        .frame(height: height)
    }
    .background(background)
    .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
    .gesture(dragGesture)
  }
}

// MARK: - UI helpers
private extension W3WSuBottomSheet {
  var background: some View {
    let color = scheme?.colors?.background?.current.suColor ?? W3WColor.background.current.suColor
    return color.edgesIgnoringSafeArea(.bottom)
  }
  
  var cornerRadius: CGFloat {
    scheme?.styles?.cornerRadius?.value ?? W3WCornerRadius.regular.value
  }
  
  var dragGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        let newHeight = self.height - (value.location.y - value.startLocation.y)
        if newHeight > 64.0 && newHeight < 700.0 {
          self.height = newHeight
        }
        if height < 0.0 {
          height = 0.0
        }
      }
      .onEnded { value in
        withAnimation {
          self.height = detents.nearest(value: height)
        }
      }
  }
}
