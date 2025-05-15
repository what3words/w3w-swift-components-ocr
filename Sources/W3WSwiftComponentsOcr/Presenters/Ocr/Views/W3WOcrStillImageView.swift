//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 05/05/2025.
//

import SwiftUI

struct W3WOcrStillImageView<ViewModel: W3WOcrViewModelProtocol>: View {
  
  // main view model
  @ObservedObject var viewModel: ViewModel
  
  var body: some View {
    VStack {
      
      if let image = viewModel.stillImage {
        Image(image, scale: 1.0, label: Text("Image"))
          .resizable()
          .scaledToFit()
          //.frame(width: 64.0, height: 64.0)
        
      } else {
        Image(systemName: "photo")
      }
    }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.gray)
  }
}


//#Preview {
  //W3WOcrStillImageView(viewModel: W3WOcrViewModel(ocr: W3WOcrNative(<#T##w3w: any W3WProtocolV4##any W3WProtocolV4#>)))
//}
