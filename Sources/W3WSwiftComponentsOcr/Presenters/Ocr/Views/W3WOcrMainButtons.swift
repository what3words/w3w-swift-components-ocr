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

  
  var body: some View {
    HStack(alignment: .center) {
      VStack {
        Button(action: { viewModel.importButtonPressed() }, label: {
          Image(systemName: "photo.badge.plus")
            .frame(width: W3WRowHeight.small.value, height: W3WRowHeight.small.value)
            .foregroundColor(.white)
            .padding(W3WPadding.bold.value)
            .background(viewModel.bottomSheetScheme?.colors?.tint?.suColor)
            .clipShape(Circle())
            .overlay(
              Circle()
                .stroke(Color.white, lineWidth: 2.0)
            )
        })
        Text(viewModel.translations.get(id: "ocr_importButton"))
          .font(scheme?.styles?.font?.caption2.suFont)
          .frame(maxWidth: .infinity)
          .foregroundColor(viewModel.bottomSheetScheme?.colors?.foreground?.suColor)
          .lineLimit(1)
          //.allowsTightening(true)
          //.minimumScaleFactor(0.8)
      }
        .padding(W3WPadding.heavy.value)

      Spacer()
        .frame(maxWidth: .infinity)

      Button(action: { viewModel.captureButtonPressed() }, label: {
        Circle()
          .frame(width: W3WRowHeight.large.value + W3WPadding.medium.value, height: W3WRowHeight.large.value + W3WPadding.medium.value)
          .overlay(
            Circle()
              .stroke(Color.white, lineWidth: W3WLineThickness.fourPoint.value)
              .frame(width: W3WRowHeight.extraLarge.value + W3WPadding.bold.value, height: W3WRowHeight.extraLarge.value + W3WPadding.bold.value)
              //.frame(width: W3WRowHeight.small.value, height: W3WRowHeight.small.value)
              //.frame(width: 56.0, height: 56.0)
          )
      })
//        .frame(width: 48.0)
        .foregroundColor(.white)
//        .padding(W3WPadding.medium.value)
//        .clipShape(Circle())
//        .overlay(
//          Circle()
//            .fill(Color.white)
//        )

      Spacer()
        .frame(maxWidth: .infinity)

      VStack {
        if #available(iOS 16.0, *) {
          Toggle("", isOn: $cameraMode)
            .frame(width: 48.0)
            .padding(W3WPadding.heavy.value)
            .tint(viewModel.bottomSheetScheme?.colors?.brand?.suColor ?? W3WColor.red.suColor)
        } else {
          Toggle("", isOn: $cameraMode)
            .frame(width: 48.0)
            .padding(W3WPadding.heavy.value)
        }
        Text(viewModel.translations.get(id: "ocr_live_scanButton"))
          .font(scheme?.styles?.font?.caption2.suFont)
          .foregroundColor(viewModel.bottomSheetScheme?.colors?.foreground?.suColor)
          .lineLimit(1)
          //.allowsTightening(true)
          //.minimumScaleFactor(0.8)
          .frame(maxWidth: .infinity)
      }
    }
  }
}


//#Preview {
//  W3WOcrMainButtons()
//}
