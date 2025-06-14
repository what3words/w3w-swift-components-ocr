//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 05/05/2025.
//

import SwiftUI
import W3WSwiftThemes


struct W3WOcrStillImageView<ViewModel: W3WOcrViewModelProtocol>: View {
  
  // main view model
  @ObservedObject var viewModel: ViewModel
  
  @State var showSpinner = true
 
  
  var body: some View {

    GeometryReader { geometry in
      VStack {
        
        if let image = viewModel.stillImage {
          //Image(image, scale: 1.0, label: Text("Image"))
          Image(uiImage: UIImage(cgImage: image))
            .resizable()
            .scaledToFit()
            //.frame(width: geometry.size.width, height: geometry.size.height)
          
        } else {
          if #available(iOS 14.0, *), showSpinner {
            ProgressView()
              .progressViewStyle(.circular)
              .foregroundColor(.white)
              .background(W3WCoreColor.darkBlue.suColor)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          } else {
            Image(systemName: "photo")
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(W3WCoreColor.darkBlue.suColor)
      .onAppear() {
        W3WThread.runIn(duration: .seconds(10.0)) {
          showSpinner = false
        }
      }
    }
  }
}


//#Preview {
  //W3WOcrStillImageView(viewModel: W3WOcrViewModel(ocr: W3WOcrNative(<#T##w3w: any W3WProtocolV4##any W3WProtocolV4#>)))
//}
