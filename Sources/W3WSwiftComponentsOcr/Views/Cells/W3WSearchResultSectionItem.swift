//
//  W3WSearchResultSection.swift
//  
//
//  Created by Thy Nguyen on 31/12/2023.
//

#if canImport(UIKit)
import UIKit
import Foundation

public enum W3WSearchResultSectionType: Int {
  case state
  case result
}

public struct W3WSearchResultSectionItem: Hashable {
  public let identifier: String
  public let type: W3WSearchResultSectionType
  public let items: [W3WSearchResultCellItem]
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  public static func == (lhs: W3WSearchResultSectionItem, rhs: W3WSearchResultSectionItem) -> Bool {
    return lhs.identifier == rhs.identifier
  }
  
  public var title: String? {
    return items.first?.title
  }
}

public extension W3WSearchResultSectionItem {
  init(type: W3WSearchResultSectionType, items: [W3WSearchResultCellItem]) {
    self.type = type
    self.items = items
    self.identifier = "\(type.rawValue)"
  }
}

public enum W3WSearchResultCellItem: Hashable {
  case state(item: W3WSingleLabelCellItem)
  case result(item: W3WSuggestionCellItem)
  
  public var title: String? {
    switch self {
    case .state(let item):
      return item.text
    default:
      return nil
    }
  }
}
#endif
