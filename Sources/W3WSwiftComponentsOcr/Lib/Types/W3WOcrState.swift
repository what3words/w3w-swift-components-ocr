//
//  W3WOcrState.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 29/04/2025.
//

public enum W3WOcrState: String, CaseIterable {
  case idle
  case detecting
  case scanning
  case scanned
  case error
}

