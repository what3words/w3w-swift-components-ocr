//
//  BorderSwitchToggleStyle.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 26/06/2025.
//

import SwiftUI
import W3WSwiftThemes
import W3WSwiftDesignSwiftUI


/// styling the SwiftUI toggle
struct BorderedSwitchToggleStyle: ToggleStyle {
  private let isLocked: Bool
  private let trackColorOn: Color
  private let trackColorOff: Color
  private let thumbColor: Color
  private let borderColor: Color
  private let borderWidth: CGFloat
  
  init(
    isLocked: Bool,
    hideLabel: Bool = true,
    trackColorOn: Color = W3WCoreColor.darkBlue.suColor,
    trackColorOff: Color = W3WCoreColor.darkBlue.suColor,
    thumbColor: Color = W3WCoreColor.white.suColor,
    borderColor: Color = W3WCoreColor.white.suColor,
    borderWidth: CGFloat = 2.0
  ) {
    self.isLocked = isLocked
    self.trackColorOn = trackColorOn
    self.trackColorOff = trackColorOff
    self.thumbColor = thumbColor
    self.borderColor = borderColor
    self.borderWidth = borderWidth
  }
  
  
  func makeBody(configuration: Configuration) -> some View {
    ZStack {
      // The background "track" of the switch
      Capsule()
        .fill(configuration.isOn ? trackColorOn : trackColorOff)
        .overlay(border(isOn: configuration.isOn))
      
      // The sliding "thumb" of the switch
      Circle()
        .fill(thumbColor)
        .shadow(radius: 1, x: 0, y: 1)
        .padding(4)
        .frame(maxWidth: .infinity, alignment: configuration.isOn ? .trailing : .leading)
      
      if isLocked {
        W3WIconImage(
          iconImage: .w3wLock,
          iconSize: 12,
          color: W3WCoreColor.white.suColor
        )
        .frame(width: 14, height: 14)
        .background(W3WTheme.what3words.brandBase?.suColor)
        .clipShape(.circle)
        .offset(x: 23.0, y: -13.0)
      }
    }
    .frame(width: 51, height: 31) // The fixed size of our switch
    .onTapGesture {
      /// The previous spring animation (`.spring(response: 0.3, dampingFraction: 0.7)`) caused
      /// the thumb to jump vertically if the parent view was being panned during the animation.
      /// Switching to a shorter `.easeInOut` animation helps reduce that visual glitch.
      withAnimation(.easeInOut(duration: 0.075)) {
        configuration.isOn.toggle()
      }
    }
  }
  
  @ViewBuilder
  private func border(isOn: Bool) -> some View {
    if !isOn {
      Capsule()
        .stroke(borderColor, lineWidth: borderWidth)
    }
  }
}
