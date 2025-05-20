//
//  File.swift
//  
//
//  Created by Dave Duprey on 05/08/2021.
//

import Foundation


class W3WOcrThread {
  
  static func runOnMain(_ block: @escaping () -> ()) {
    if Thread.current.isMainThread {
      block()
    } else {
      DispatchQueue.main.async {
        block()
      }
    }
  }
  
}
