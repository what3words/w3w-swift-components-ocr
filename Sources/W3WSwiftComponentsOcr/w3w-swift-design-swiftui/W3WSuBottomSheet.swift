//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 02/05/2025.
//


import SwiftUI
import W3WSwiftThemes

public struct W3WSuBottomSheet<Accessory: View, Content: View>: View {
  /// An enum used as a unique identifier for tracking the height of different view components
  private enum Height {
    case content
  }
  
  public let scheme: W3WScheme?
  
  @State var height: CGFloat
  
  var onHeightChange: ((CGFloat) -> Void) = { _ in }
  
  let detents: W3WDetents
  
  @ViewBuilder let accessory: () -> Accessory
  
  @ViewBuilder let content: () -> Content
  
  
  public var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        accessory()
        VStack {
          W3WCoreColor(hex: 0x3D3D3D).suColor
            .background(W3WCoreColor(hex: 0x7F7F7F).suColor.opacity(0.4))
            .opacity(0.5)
            .frame(width: 36, height: 5)
            .clipShape(.capsule)
            .padding(W3WPadding.medium.value)
          
          content()
        }
        .background(background)
        .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
        .gesture(dragGesture(maxHeight: geometry.size.height))
      }
      .frame(height: height)
      .onSizeChange({ onHeightChange($0.height) }, for: Height.content)
      .frame(maxHeight: .infinity, alignment: .bottom)
      .background(
        // Hackaround to force a background at the bottom area
        background
          .frame(height: geometry.safeAreaInsets.bottom)
          .frame(maxHeight: .infinity, alignment: .bottom)
      )
    }
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
  
  func dragGesture(maxHeight: CGFloat) -> some Gesture {
    DragGesture()
      .onChanged { value in
        let newHeight = self.height - (value.location.y - value.startLocation.y)
        if newHeight > 64.0 && newHeight < maxHeight {
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

public extension W3WSuBottomSheet where Accessory == EmptyView {
  init(
    scheme: W3WScheme?,
    height: CGFloat,
    onHeightChange: @escaping (CGFloat) -> Void = { _ in },
    detents: W3WDetents,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.scheme = scheme
    self.height = height
    self.onHeightChange = onHeightChange
    self.detents = detents
    self.accessory = { EmptyView() }
    self.content = content
  }
}
