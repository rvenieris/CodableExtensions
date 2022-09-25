// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodableExtensions",
    platforms: [
        .iOS(.v10),
        .tvOS(.v9),
        .watchOS(.v4),
        .macOS(.v10_13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CodableExtensions",
            targets: ["CodableExtensions"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CodableExtension",
            dependencies: [],
            swiftSettings: [.define("APPLICATION_EXTENSION_API_ONLY=YES")]),
        .testTarget(
            name: "CodableExtensionTests",
            dependencies: ["CodableExtension"],
            swiftSettings: [.define("APPLICATION_EXTENSION_API_ONLY=YES")]),
    ]
)