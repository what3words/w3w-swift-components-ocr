//
//  W3WDetents.swift
//
//
//  Created by Dave Duprey on 13/09/2023.
//

import Foundation


/// a store of positions that a view may move to
@available(*, deprecated, message: "delete this class and make the one in W3WSwiftDesign public, and maybe moce to W3WSwiftTheme so it can be used in both")
public struct W3WDetents {
  
  var detents = [CGFloat]()

  
  public init(detent: CGFloat) {
    add(detent: detent)
  }


  public init(detents: [CGFloat]) {
    add(detents: detents)
  }


  public mutating func add(detent: CGFloat) {
    detents.append(detent)
  }
  
  
  public mutating func add(detents arr: [CGFloat]) {
    detents.append(contentsOf: arr)
  }
  
  
  public mutating func remove(detent: CGFloat) {
    detents.removeAll(where: { d in d == detent })
  }
  
  
  public mutating func removeDetents() {
    detents.removeAll()
  }

  
  public func nearest(value: CGFloat) -> CGFloat {
    var retval = 0.0
    var distance = CGFloat.greatestFiniteMagnitude
    
    for detent in detents {
      if abs(value - detent) < distance {
        distance = abs(value - detent)
        retval = detent
      }
    }
    
    return retval
  }
  
  
}
