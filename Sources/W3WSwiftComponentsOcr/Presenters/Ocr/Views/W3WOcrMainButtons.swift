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
  
  @Binding var cameraMode: Bool

  
  var body: some View {
    HStack(alignment: .center) {
      Button(action: { viewModel.importButtonPressed() }, label: {
        Image(systemName: "photo.badge.plus")
          .frame(width: 48.0)
          .foregroundColor(.white)
          .padding(W3WPadding.bold.value)
          .clipShape(Circle())
          .overlay(
            Circle()
              .stroke(Color.white, lineWidth: 2.0)
          )
      })

      Spacer()
        .frame(maxWidth: .infinity)

      Button(action: { viewModel.captureButtonPressed() }, label: {
        Circle()
          .frame(width: 48.0, height: 48.0)
          .overlay(
            Circle()
              .stroke(Color.white, lineWidth: 2.0)
              .frame(width: 56.0, height: 56.0)
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

      Toggle("", isOn: $cameraMode)
        .frame(width: 48.0)
        .padding(W3WPadding.heavy.value)
        //.toggleStyle(SwitchToggleStyle(tint: viewModel.scheme?.colors?.tint?.current.suColor ?? W3WColor.darkerCyan.suColor))
    }
  }
}


//#Preview {
//  W3WOcrMainButtons()
//}
