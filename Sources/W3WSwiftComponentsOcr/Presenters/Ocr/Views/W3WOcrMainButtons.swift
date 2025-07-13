//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 05/05/2025.
//

import SwiftUI
import W3WSwiftDesign
import W3WSwiftDesignSwiftUI


/// the import, capture and live/still mode switch
struct W3WOcrMainButtons<ViewModel: W3WOcrViewModelProtocol>: View {
  
  /// main view model
  @ObservedObject var viewModel: ViewModel
  
  /// the scheme to use
  var scheme: W3WScheme? = .w3w
  
  /// the live/still switch state
  @Binding var cameraMode: Bool
  
  /// padding for the buttons
  let buttonsPadding: CGFloat = 32.0
  
  /// inner diameter for the capture button
  let innerCircleDiameter: CGFloat = 60.0
  
  /// outer diameter for the capture button
  let outerCircleDiameter: CGFloat = 70.0
  
  var body: some View {
    ZStack {
      HStack {
        importButton
        Spacer()
        liveStillToggle
      }
      .padding(.horizontal, buttonsPadding)
      .font(scheme?.styles?.font?.caption2.suFont)
      .foregroundColor(viewModel.bottomSheetScheme?.colors?.foreground?.suColor)
      .lineLimit(1)
      
      // capture button
      Button(action: viewModel.captureButtonPressed) {
        Circle()
          .frame(width: innerCircleDiameter, height: innerCircleDiameter)
          .overlay(
            Circle()
              .stroke(viewModel.viewType == .video ? W3WColor.white.with(alpha: 0.8).suColor : W3WColor.white.suColor, lineWidth: W3WLineThickness.fourPoint.value)
              .frame(width: outerCircleDiameter, height: outerCircleDiameter)
          )
      }
      .foregroundColor(viewModel.viewType == .video ? W3WColor.white.with(alpha: 0.8).suColor : W3WColor.white.suColor)
      .disabled(viewModel.viewType == .video)
    }
    .padding(.bottom, W3WMargin.three.value)
  }
  
  private var importButton: some View {
    VStack(spacing: 8) {
      Button(action: { viewModel.importButtonPressed() }, label: {
        Image(systemName: "photo.badge.plus")
          .frame(width: W3WRowHeight.medium.value, height: W3WRowHeight.medium.value)
          .foregroundColor(.white)
          .background(W3WCoreColor.darkBlue.suColor)
          .clipShape(.circle)
          .overlay(
            Circle()
              .stroke(Color.white, lineWidth: 2.0)
          )
      })
      .disabled(viewModel.lockOnImportButton)
      .isLockedOcr(viewModel.lockOnImportButton, alignment: .topTrailing) //, offsetX: 32.0, offsetY: 32.0, lockColor: .red)
      // if the button is disabled, we still need to send back the tap so the app can show a payment page
      .onTapGesture {
        if viewModel.lockOnImportButton {
          viewModel.importButtonPressed()
        }
      }
      
      Text(viewModel.translations.get(id: "ocr_importButton"))
    }
  }
  
  private var liveStillToggle: some View {
    @ViewBuilder
    var toggle: some View {
      if #available(iOS 16.0, *) {
        Toggle("", isOn: $cameraMode)
          .tint(viewModel.bottomSheetScheme?.colors?.brand?.suColor ?? W3WColor.red.suColor)
      } else {
        Toggle("", isOn: $cameraMode)
      }
    }
    
    return VStack(spacing: 8) {
      toggle
        .disabled(viewModel.lockOnLiveSwitch)
        .frame(width: 60, height: W3WRowHeight.medium.value)
        .toggleStyle(BorderedSwitchToggleStyle(isLocked: viewModel.lockOnLiveSwitch, trackColorOn: viewModel.bottomSheetScheme?.colors?.brand?.suColor ?? W3WColor.red.suColor, borderColor: .white))
        .onTapGesture { // if the toggle is disabled, we still need to send back the tap so the app can show a payment page
          if viewModel.lockOnLiveSwitch {
            viewModel.viewTypeSwitchEvent(on: cameraMode)
          }
        }
      Text(viewModel.translations.get(id: "ocr_live_scanButton"))
    }
  }
}

