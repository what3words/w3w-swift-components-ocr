//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 24/06/2025.
//

import SwiftUI
import W3WSwiftThemes
import W3WSwiftComponentsOcr


struct W3WSuOcrMockView: View {
  
  
  let ocrView: UIView
  
  
  public init(ocrView: UIView) {
    self.ocrView = ocrView
  }
 
  
  var body: some View {
    VStack {
      Spacer().frame(maxWidth: .infinity, maxHeight: 128.0)
      VStack {
        Text("filled.count.soap")
        Text("index.home.raft")
        Text("daring.lion.race")
      }
      .frame(width: 256.0, height: 256.0)
      .padding()
      .background(W3WColor.lightBlue.suColor)
      .border(.white)
      Spacer()
    }
    .background(W3WColor.darkBlue.with(alpha: 0.5).suColor)
//    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}


#Preview {
  W3WSuOcrMockView(ocrView: UIView())
}
