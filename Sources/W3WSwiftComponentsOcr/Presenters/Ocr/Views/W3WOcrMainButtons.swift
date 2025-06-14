//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 05/05/2025.
//

import SwiftUI
import W3WSwiftDesign
import W3WSwiftDesignSwiftUI


struct W3WOcrMainButtons<ViewModel: W3WOcrViewModelProtocol>: View {
  
  // main view model
  @ObservedObject var viewModel: ViewModel
  
  var scheme: W3WScheme? = .w3w
  
  @Binding var cameraMode: Bool

  
  let iconPadding: CGFloat = 72.0

  let toggleSize: CGFloat = 48.0

  
  var body: some View {
    ZStack {
      VStack {
        HStack {
          Button(action: { viewModel.importButtonPressed() }, label: {
            Image(systemName: "photo.badge.plus")
              .frame(width: W3WRowHeight.extraSmall.value, height: W3WRowHeight.extraSmall.value)
              .foregroundColor(.white)
              .padding(W3WPadding.bold.value)
              //.background(viewModel.bottomSheetScheme?.colors?.tint?.suColor)
              .background(W3WCoreColor.darkBlue.suColor)
              .clipShape(Circle())
              .overlay(
                Circle()
                  .stroke(Color.white, lineWidth: 2.0)
              )
          })
          .frame(width: iconPadding)


          Spacer()

          if #available(iOS 16.0, *) {
            Toggle("", isOn: $cameraMode)
              .frame(width: toggleSize)
              .tint(viewModel.bottomSheetScheme?.colors?.brand?.suColor ?? W3WColor.red.suColor)
              .toggleStyle(BorderedSwitchToggleStyle(trackColorOn: viewModel.bottomSheetScheme?.colors?.brand?.suColor ?? W3WColor.red.suColor, borderColor: .white))
              .frame(width: iconPadding)
          } else {
            Toggle("", isOn: $cameraMode)
              .frame(width: toggleSize)
              .toggleStyle(BorderedSwitchToggleStyle(trackColorOn: viewModel.bottomSheetScheme?.colors?.brand?.suColor ?? W3WColor.red.suColor, borderColor: .white))
              .frame(width: iconPadding)
          }

        }
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
    
    
//    HStack(alignment: .center) {
//      VStack {
//        Button(action: { viewModel.importButtonPressed() }, label: {
//          Image(systemName: "photo.badge.plus")
//            .frame(width: W3WRowHeight.extraSmall.value, height: W3WRowHeight.extraSmall.value)
//            .foregroundColor(.white)
//            .padding(W3WPadding.bold.value)
//            .background(viewModel.bottomSheetScheme?.colors?.tint?.suColor)
//            .clipShape(Circle())
//            .overlay(
//              Circle()
//                .stroke(Color.white, lineWidth: 2.0)
//            )
//        })
//        Text(viewModel.translations.get(id: "ocr_importButton"))
//          .font(scheme?.styles?.font?.caption2.suFont)
//          .frame(maxWidth: .infinity)
//          .foregroundColor(viewModel.bottomSheetScheme?.colors?.foreground?.suColor)
//          .lineLimit(1)
//      }
//      .padding(.leading, W3WPadding.heavy.value)
//
//      Spacer()
//        .frame(maxWidth: .infinity)
//
//      Button(action: { viewModel.captureButtonPressed() }, label: {
//        Circle()
//          .frame(width: W3WRowHeight.large.value + W3WPadding.medium.value, height: W3WRowHeight.large.value + W3WPadding.medium.value)
//          .overlay(
//            Circle()
//              .stroke(Color.white, lineWidth: W3WLineThickness.fourPoint.value)
//              .frame(width: W3WRowHeight.extraLarge.value + W3WPadding.bold.value, height: W3WRowHeight.extraLarge.value + W3WPadding.bold.value)
//          )
//      })
//        .foregroundColor(.white)
//
//      Spacer()
//        .frame(maxWidth: .infinity)
//
//      VStack {
//        if #available(iOS 16.0, *) {
//          Toggle("", isOn: $cameraMode)
//            .frame(width: 48.0)
//            .tint(viewModel.bottomSheetScheme?.colors?.brand?.suColor ?? W3WColor.red.suColor)
//            .toggleStyle(BorderedSwitchToggleStyle(borderColor: .white))
//        } else {
//          Toggle("", isOn: $cameraMode)
//            .frame(width: 48.0)
//            .toggleStyle(BorderedSwitchToggleStyle(borderColor: .white))
//        }
//        Text(viewModel.translations.get(id: "ocr_live_scanButton"))
//          .font(scheme?.styles?.font?.caption2.suFont)
//          .foregroundColor(viewModel.bottomSheetScheme?.colors?.foreground?.suColor)
//          .lineLimit(1)
//          .padding(0.0)
//      }
//      .padding(.trailing, W3WPadding.heavy.value)
//    }
  }
}


//#Preview {
//  W3WOcrMainButtons()
//}


struct BorderedSwitchToggleStyle: ToggleStyle {
  
  // Define the colors and sizes we'll use
  private let trackColorOn: Color
  private let trackColorOff: Color
  private let thumbColor: Color
  private let borderColor: Color
  private let borderWidth: CGFloat
  
  
  init(trackColorOn: Color = W3WCoreColor.darkBlue.suColor, trackColorOff: Color = W3WCoreColor.darkBlue.suColor, thumbColor: Color = W3WCoreColor.white.suColor, borderColor: Color = W3WCoreColor.white.suColor, borderWidth: CGFloat = 2.0) {
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
      configuration.label
      
      Spacer()
      
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
