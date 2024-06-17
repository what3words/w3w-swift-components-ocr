//
//  W3WOcrStartViewController.swift
//
//
//  Created by Thy Nguyen on 12/01/2024.
//

import UIKit
import W3WSwiftDesign
import W3WSwiftCore

open class W3WOcrStartViewController: W3WViewController {
  
  public var onButtonPressed: () -> () = { }

  var button: W3WButton!
  var logo: W3WIconView!
  
  override open func viewDidLoad() {
    
    button = W3WButton(label: "Start Scanning", scheme: .w3wButtonFilled.with(background: W3WColor.w3wBrandBase))
    logo   = W3WIconView(image: .w3wLogoWithText)
    
    add(view: button, position: .bottomButton())
    add(view: logo, position: .center(size: CGSize(width: 143.0, height: 24.0)))
    
    button.onTap = { [weak self] in
      self?.onButtonPressed()
    }
  }
  
}

