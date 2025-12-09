//
//  SwiftUIView.swift
//  w3w-swift-app-presenters
//
//  Created by Dave Duprey on 04/04/2025.
//

import SwiftUI
import W3WSwiftThemes


public struct W3WTextView: View {
  
  var text: W3WString
  
  var separator: Bool
  
  public init(_ text: W3WString, separator: Bool = false) {
    self.text = text
    self.separator = separator
  }
  
  public var body: some View {
    if #available(iOS 15.0, *) {
      Text(AttributedString(text.asAttributedString()))
        .listRowSeparator(separator ? .automatic : .hidden)
      
    } else {
      Text(text.asString())
    }
  }
  
}

#Preview {
  W3WTextView("test.test.test".w3w.withSlashes())
}
