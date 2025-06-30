//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 05/05/2025.
//

import SwiftUI
import W3WSwiftThemes

/// the image view, defaults to spinner or image icon depending on iOS version
struct W3WOcrStillImageView<ViewModel: W3WOcrStillViewModelProtocol>: View {
  
  // main view model  - maybe reduce this to just the image?
  @ObservedObject var viewModel: ViewModel
  
  
  var body: some View {

    GeometryReader { geometry in
      VStack {

        // show the image
        if let image = viewModel.image {
          Image(uiImage: UIImage(cgImage: image))
            .resizable()
            .scaledToFit()
          
        // if not image show a placeholder
        } else {
          // iOS 15+ show progress spinner
          if #available(iOS 15.0, *) {
            ProgressView()
              .progressViewStyle(.circular)
              .tint(.white)
            
          // iOS 14- show image icon
          } else {
            Image(systemName: "photo")
              .foregroundColor(.white)
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(W3WCoreColor.darkBlue.suColor)
    }
  }
}

