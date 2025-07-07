//
//  W3WCornerMarkers.swift
//  w3w-swift-components-ocr
//
//  Created by Hoang Ta on 7/7/25.
//

import SwiftUI

struct W3WCornerMarkers: View {
  let lineLength: CGFloat
  let lineWidth: CGFloat
  var color: Color = .white
  
  var body: some View {
    Shape(lineLength: lineLength, lineWidth: lineWidth)
      .stroke(color, lineWidth: lineWidth)
  }
}

private extension W3WCornerMarkers {
  struct Shape: SwiftUI.Shape {
    let lineLength: CGFloat
    let lineWidth: CGFloat
    
    func path(in rect: CGRect) -> Path {
      var path = Path()
      
      let w = rect.width
      let h = rect.height
      let halfLineWidth = lineWidth / 2
      
      // Top-left
      path.move(to: CGPoint(x: -halfLineWidth, y: 0))
      path.addLine(to: CGPoint(x: lineLength, y: 0))
      path.move(to: CGPoint(x: 0, y: -halfLineWidth))
      path.addLine(to: CGPoint(x: 0, y: lineLength))
      
      // Top-right
      path.move(to: CGPoint(x: w + halfLineWidth, y: 0))
      path.addLine(to: CGPoint(x: w - lineLength, y: 0))
      path.move(to: CGPoint(x: w, y: -halfLineWidth))
      path.addLine(to: CGPoint(x: w, y: lineLength))
      
      // Bottom-left
      path.move(to: CGPoint(x: -halfLineWidth, y: h))
      path.addLine(to: CGPoint(x: lineLength, y: h))
      path.move(to: CGPoint(x: 0, y: h + halfLineWidth))
      path.addLine(to: CGPoint(x: 0, y: h - lineLength))
      
      // Bottom-right
      path.move(to: CGPoint(x: w + halfLineWidth, y: h))
      path.addLine(to: CGPoint(x: w - lineLength, y: h))
      path.move(to: CGPoint(x: w, y: h + halfLineWidth))
      path.addLine(to: CGPoint(x: w, y: h - lineLength))
      
      return path
    }
  }
}
