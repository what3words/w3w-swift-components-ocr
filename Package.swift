// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "w3w-swift-components-ocr",
    defaultLocalization: "en",
    platforms: [
      .macOS(.v10_13), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "W3WSwiftComponentsOcr",
            targets: ["W3WSwiftComponentsOcr"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
      .package(url: "https://github.com/what3words/w3w-swift-core.git", branch: "staging"),
      .package(url: "https://github.com/what3words/w3w-swift-design.git", branch: "staging"),
      .package(url: "git@github.com:what3words/w3w-swift-design-swiftui.git", branch: "staging"),
      .package(url: "git@github.com:w3w-internal/w3w-swift-app-events.git", branch: "staging"),
      .package(url: "https://github.com/what3words/w3w-swift-presenters.git", branch: "staging"),
      .package(url: "git@github.com:w3w-internal/w3w-swift-app-types.git", branch: "staging")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "W3WSwiftComponentsOcr",
            dependencies: [
              .product(name: "W3WSwiftCore", package: "w3w-swift-core"),
              .product(name: "W3WSwiftDesign", package: "w3w-swift-design"),
              .product(name: "W3WSwiftDesignSwiftUI", package: "w3w-swift-design-swiftui"),
              .product(name: "W3WSwiftPresenters", package: "w3w-swift-presenters"),
              .product(name: "W3WSwiftAppEvents", package: "w3w-swift-app-events"),
              .product(name: "W3WSwiftAppTypes", package: "w3w-swift-app-types")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "w3w-swift-components-ocrTests",
            dependencies: ["W3WSwiftComponentsOcr"]),
    ]
)
