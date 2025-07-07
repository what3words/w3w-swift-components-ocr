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
  // Define the colors and sizes we'll use
  private let trackColorOn: Color
  private let trackColorOff: Color
  private let thumbColor: Color
  private let borderColor: Color
  private let borderWidth: CGFloat
  let isLocked: Bool // Add this new property
  let hideLabel: Bool
  
  init(isLocked: Bool, hideLabel: Bool = true, trackColorOn: Color = W3WCoreColor.darkBlue.suColor, trackColorOff: Color = W3WCoreColor.darkBlue.suColor, thumbColor: Color = W3WCoreColor.white.suColor, borderColor: Color = W3WCoreColor.white.suColor, borderWidth: CGFloat = 2.0) {
    self.isLocked = isLocked
    self.hideLabel = hideLabel
    self.trackColorOn = trackColorOn
    self.trackColorOff = trackColorOff
    self.thumbColor = thumbColor
    self.borderColor = borderColor
    self.borderWidth = borderWidth
  }
  
  
  // This is the main function that creates the view for the toggle
  func makeBody(configuration: Configuration) -> some View {
    // A HStack to hold the label and our custom switch
    HStack {
      if !hideLabel {
        configuration.label
        Spacer()
      }
      
      // This ZStack creates our custom switch component
      ZStack {
        // The background "track" of the switch
        Capsule()
          .fill(configuration.isOn ? trackColorOn : trackColorOff)
        // The main fix: We apply the border as an overlay on the track
          .overlay(
            Capsule()
              .stroke(borderColor, lineWidth: borderWidth)
          )
        
        // The sliding "thumb" of the switch
        Circle()
          .fill(thumbColor)
          .shadow(radius: 1, x: 0, y: 1) // A subtle shadow for depth
          .padding(4) // Padding to keep the thumb inside the track
        
        // Position the thumb based on the toggle's state
          .offset(x: configuration.isOn ? 10 : -10)

        
        if isLocked { // Use the new isLocked property
              // The lock icon, positioned relative to the 51x31 ZStack
              W3WIconImage(
                  iconImage: .w3wLock,
                  iconSize: 12,
                  color: W3WCoreColor.white.suColor // Use your desired lockColor
              )
              .frame(width: 14, height: 14)
              .background(W3WTheme.what3words.brandBase?.suColor)
              .clipShape(.circle)
              .offset(x: 23.0, y: -13.0)
          }

        
      }
      .frame(width: 51, height: 31) // The fixed size of our switch
      .onTapGesture {
        // IMPORTANT: This makes the custom view interactive
        // We wrap the state change in an animation block
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
          configuration.isOn.toggle()
        }
      }
    }
  }
}
