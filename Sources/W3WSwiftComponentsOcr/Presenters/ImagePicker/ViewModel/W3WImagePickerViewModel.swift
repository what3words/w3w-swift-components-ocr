//
//  W3WImagePickerViewModel.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 06/05/2025.
//

import W3WSwiftCore


public class W3WImagePickerViewModel: W3WImagePickerViewModelProtocol {
  
  public var input = W3WEvent<W3WImagePickerInputEvent>()
  
  public var output = W3WEvent<W3WImagePickerOutputEvent>()
  
  public init() {
  }
  
}
