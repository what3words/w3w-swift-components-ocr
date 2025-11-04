//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 02/05/2025.
//


import SwiftUI
import W3WSwiftThemes
import W3WSwiftDesignSwiftUI

public struct W3WSuBottomSheet<Accessory: View, Content: View>: View {
  /// An enum used as a unique identifier for tracking the height of different view components
  private enum Height {
    case content
  }
  
  private enum HeightMode {
    case fixed
    case binding(Binding<CGFloat>)
  }
  
  public let scheme: W3WScheme?
  
  private let heightMode: HeightMode
  
  private let maxHeight: CGFloat?
  
  let detents: W3WDetents
  
  @ViewBuilder let accessory: () -> Accessory
  
  @ViewBuilder let content: () -> Content
  
  public init(
    scheme: W3WScheme?,
    height: Binding<CGFloat>?,
    maxHeight: CGFloat? = nil,
    detents: W3WDetents,
    @ViewBuilder accessory: @escaping () -> Accessory,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.scheme = scheme
    if let height {
      self.heightMode = .binding(height)
    } else {
      self.heightMode = .fixed
    }
    self.maxHeight = maxHeight
    self.detents = detents
    self.accessory = accessory
    self.content = content
  }
  
  public var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        accessory()
        panelContent(maxHeight: maxHeight ?? geometry.size.height)
      }
      .frame(height: height)
      .fixedSize(horizontal: false, vertical: true)
      .frame(maxHeight: .infinity, alignment: .bottom)
      .background(
        background // Hackaround to force a background at the bottom area
          .frame(height: geometry.safeAreaInsets.bottom)
          .frame(maxHeight: .infinity, alignment: .bottom)
      )
    }
  }
}

// MARK: - UI helpers
private extension W3WSuBottomSheet {
  var height: CGFloat? {
    switch heightMode {
    case .fixed:
      return nil
    case .binding(let binding):
      return binding.wrappedValue
    }
  }
    
  @ViewBuilder
  func panelContent(maxHeight: CGFloat) -> some View {
    let panelContent = VStack {
      W3WCoreColor(hex: 0x3D3D3D).suColor
        .background(W3WCoreColor(hex: 0x7F7F7F).suColor.opacity(0.4))
        .opacity(0.5)
        .frame(width: 36, height: 5)
        .clipShape(.capsule)
        .padding(W3WPadding.medium.value)
      
      content()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .background(background)
    .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
    
    switch heightMode {
    case .fixed:
      panelContent
      
    case .binding(let height):
      panelContent
        .gesture(DragGesture()
          .onChanged { value in
            let newHeight = height.wrappedValue - (value.location.y - value.startLocation.y)
            if newHeight < W3WRowHeight.large.value {
              height.wrappedValue = W3WRowHeight.large.value
            } else if newHeight > maxHeight {
              height.wrappedValue = maxHeight
            } else {
              height.wrappedValue = newHeight
            }
          }
          .onEnded { value in
            withAnimation {
              height.wrappedValue = detents.nearest(value: height.wrappedValue)
            }
          }
        )
    }
  }
  
  var background: some View {
    let color = scheme?.colors?.background?.current.suColor ?? W3WColor.background.current.suColor
    return color.edgesIgnoringSafeArea(.bottom)
  }
  
  var cornerRadius: CGFloat {
    scheme?.styles?.cornerRadius?.value ?? W3WCornerRadius.regular.value
  }
}

// MARK: - Convenient constructors
public extension W3WSuBottomSheet where Accessory == EmptyView {
  init(
    scheme: W3WScheme?,
    height: Binding<CGFloat>?,
    maxHeight: CGFloat? = nil,
    detents: W3WDetents,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.init(
      scheme: scheme,
      height: height,
      maxHeight: maxHeight,
      detents: detents,
      accessory: { EmptyView() },
      content: content
    )
  }
}
