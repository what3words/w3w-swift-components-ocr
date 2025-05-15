//
//  W3WMultiPurposeItemViewModelProtocol.swift
//  w3w-swift-app-presenters
//
//  Created by Dave Duprey on 31/03/2025.
//

import SwiftUI
import W3WSwiftCore
import W3WSwiftThemes


public protocol W3WPanelViewModelProtocol: ObservableObject {
  
  var items: W3WPanelItemList { get set }
  
  var input: W3WEvent<W3WPanelInputEvent> { get set }
  
  var output: W3WEvent<W3WPanelOutputEvent> { get set }
  
  //var scheme: W3WScheme? { get set }

}
