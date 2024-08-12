//
//  ViewController.swift
//  BuildOcr
//
//  Created by Dave Duprey on 12/08/2024.
//

import UIKit
import W3WSwiftCore
import W3WSwiftComponentsOcr


class ViewController: W3WOcrViewController {

  lazy var api = MockApi()
  
  lazy var ocr = W3WOcrNative(api)
  
  public var foundSuggestion: W3WSuggestion?

  override func viewDidLoad() {
    W3WSettings.simulated3WordAddresses = ["index.home.raft"]

    view.accessibilityIdentifier = "main.view"
    
    super.viewDidLoad()
    
    set(ocr: ocr)
    
    start()
    
    // when the user taps on a suggestion, stop and dismiss the component
    onReceiveRawSuggestions = { [unowned self] suggestions in
      stop()
      
      for suggestion in suggestions {
        foundSuggestion = suggestion
      }
    }
    
    onError = { error in
      print(error)
    }

  }


}

