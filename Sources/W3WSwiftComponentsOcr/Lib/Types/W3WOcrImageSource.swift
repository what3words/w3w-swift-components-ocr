//
//  W3WOcrImageSource.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 22/07/2025.
//

public enum W3WOcrImageSource: CustomStringConvertible {
  
  case photoLibrary
  case camera
  case unknown
  case other(String)

  public var description: String {
    switch self {
        
      case .photoLibrary:
        return "photoLibrary"
        
      case .camera:
        return "camera"
        
      case .unknown:
        return "unknown"
        
      case .other(let other):
        return other
    }
  }

}
