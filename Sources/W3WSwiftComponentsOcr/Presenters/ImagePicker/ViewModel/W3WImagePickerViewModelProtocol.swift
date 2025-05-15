//
//  W3WImagePickerViewModelProtocol.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 06/05/2025.
//

import CoreGraphics
import W3WSwiftCore


public protocol W3WImagePickerViewModelProtocol {
  
  var input: W3WEvent<W3WImagePickerInputEvent> { get set }
  
  var output: W3WEvent<W3WImagePickerOutputEvent> { get set }
  
}
