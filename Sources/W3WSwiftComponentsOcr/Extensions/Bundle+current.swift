//
//  Bundle+module.swift
//  
//
//  Created by Thy Nguyen on 23/01/2024.
//

import Foundation

extension Bundle {
  static let current: Bundle = {
#if DEBUG
    if let moduleName = Bundle(for: BundleFinder.self).bundleIdentifier,
       let testBundlePath = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] {
      if let resourceBundle = Bundle(path: testBundlePath + "/\(moduleName)_\(moduleName).bundle") {
        return resourceBundle
      }
    }
    return Bundle(for: BundleFinder.self)
#else
    return Bundle.module
#endif
  }()
  
  private final class BundleFinder {}
}
