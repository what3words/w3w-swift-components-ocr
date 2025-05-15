//
//  W3WSuOcrView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import UIKit
import SwiftUI
import W3WSwiftThemes


struct W3WSuOcrView: UIViewRepresentable {
  
  //let ocrView = W3WOcrView(frame: UIScreen.main.bounds)
  
  let ocrView: W3WOcrView
  
  
  public init(ocrView: W3WOcrView) {
    self.ocrView = ocrView
  }
  
  
  func makeUIView(context: Context) -> W3WOcrView {
    return ocrView
  }
  
  
  func updateUIView(_ uiView: W3WOcrView, context: Context) {
    //DispatchQueue.main.async { [ocrView] in
    //  ocrView.set(crop: defaultCrop())
    //}
  }
  
}
