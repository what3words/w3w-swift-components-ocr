// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "w3w-swift-components-ocr",
    platforms: [
      .macOS(.v10_11), .iOS(.v9), .tvOS(.v11), .watchOS(.v2)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "W3WSwiftComponentsOcr",
            targets: ["W3WSwiftComponentsOcr"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
      .package(url: "https://github.com/what3words/w3w-swift-wrapper.git", "3.6.0"..<"4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "W3WSwiftComponentsOcr",
            dependencies: [
              .product(name: "W3WSwiftApi", package: "w3w-swift-wrapper"),
            ]),
        .testTarget(
            name: "w3w-swift-components-ocrTests",
            dependencies: ["W3WSwiftComponentsOcr"]),
    ]
)
