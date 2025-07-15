//
//  W3WCProgressView.swift
//  w3w-swift-components-ocr
//
//  Created by Hoang Ta on 11/7/25.
//


import SwiftUI
import UIKit

struct W3WProgressView: UIViewRepresentable {
  let color: UIColor
  
  func makeUIView(context: Context) -> UIActivityIndicatorView {
    let indicator = UIActivityIndicatorView()
    indicator.color = color
    indicator.startAnimating()
    return indicator
  }
  
  func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}
