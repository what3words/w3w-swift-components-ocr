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

  /// padding for the icon
  let iconPadding: CGFloat = 72.0

  /// size for the toggle
  let toggleSize: CGFloat = 48.0

  
  var body: some View {
    ZStack {
      VStack {
        HStack {
          
          // Import button
          Button(action: { viewModel.importButtonPressed() }, label: {
            Image(systemName: "photo.badge.plus")
              .frame(width: W3WRowHeight.extraSmall.value, height: W3WRowHeight.extraSmall.value)
              .foregroundColor(.white)
              .padding(W3WPadding.bold.value)
              .background(W3WCoreColor.darkBlue.suColor)
              .clipShape(Circle())
              .overlay(
                Circle()
                  .stroke(Color.white, lineWidth: 2.0)
              )
          })
          .frame(width: iconPadding)
          .disabled(viewModel.lockOnImportButton)
          .isLockedOcr(viewModel.lockOnImportButton, alignment: .topTrailing) //, offsetX: 32.0, offsetY: 32.0, lockColor: .red)
          // if the button is disabled, we still need to send back the tap so the app can show a payment page
          .onTapGesture {
            if viewModel.lockOnImportButton {
              viewModel.importButtonPressed()
            }
          }


          Spacer()

          // live/still toggle
          if #available(iOS 16.0, *) {
            Toggle("", isOn: $cameraMode)
              .frame(width: toggleSize)
              .tint(viewModel.bottomSheetScheme?.colors?.brand?.suColor ?? W3WColor.red.suColor)
              .toggleStyle(BorderedSwitchToggleStyle(isLocked: viewModel.lockOnLiveSwitch, trackColorOn: viewModel.bottomSheetScheme?.colors?.brand?.suColor ?? W3WColor.red.suColor, borderColor: .white))
              .frame(width: iconPadding)
              .disabled(viewModel.lockOnLiveSwitch)
              .onTapGesture { // if the toggle is disabled, we still need to send back the tap so the app can show a payment page
                if viewModel.lockOnLiveSwitch {
                  viewModel.viewTypeSwitchEvent(on: cameraMode)
                }
              }
          } else {
            Toggle("", isOn: $cameraMode)
              .frame(width: toggleSize)
              //.toggleStyle(BorderedSwitchToggleStyle(trackColorOn: viewModel.bottomSheetScheme?.colors?.brand?.suColor ?? W3WColor.red.suColor, borderColor: .white))
              .frame(width: iconPadding)
              .disabled(viewModel.lockOnLiveSwitch)
              .isLockedOcr(viewModel.lockOnLiveSwitch, alignment: .topTrailing, offsetX: -12.0, offsetY: -12.0) //, lockColor: .red)
              .onTapGesture { // if the toggle is disabled, we still need to send back the tap so the app can show a payment page
                if viewModel.lockOnLiveSwitch {
                  viewModel.viewTypeSwitchEvent(on: cameraMode)
                }
              }
          }
        }
        
        // button text
        HStack {
          Text(viewModel.translations.get(id: "ocr_importButton"))
            .font(scheme?.styles?.font?.caption2.suFont)
            //.frame(maxWidth: .infinity)
            .foregroundColor(viewModel.bottomSheetScheme?.colors?.foreground?.suColor)
            .lineLimit(1)
            .frame(width: iconPadding)

          Spacer()
          
          Text(viewModel.translations.get(id: "ocr_live_scanButton"))
            .font(scheme?.styles?.font?.caption2.suFont)
            .foregroundColor(viewModel.bottomSheetScheme?.colors?.foreground?.suColor)
            .lineLimit(1)
            //.padding(0.0)
            .frame(width: iconPadding)
        }
      }
      
      HStack {
        
        // capture button
        Button(action: { viewModel.captureButtonPressed() }, label: {
          Circle()
            .frame(width: W3WRowHeight.large.value + W3WPadding.medium.value, height: W3WRowHeight.large.value + W3WPadding.medium.value)
            .overlay(
              Circle()
                .stroke(Color.white, lineWidth: W3WLineThickness.fourPoint.value)
                .frame(width: W3WRowHeight.extraLarge.value + W3WPadding.bold.value, height: W3WRowHeight.extraLarge.value + W3WPadding.bold.value)
            )
        })
          .foregroundColor(.white)
      }
    }
    .padding()
    
  }
}

