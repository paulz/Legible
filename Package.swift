// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Legible",
    platforms: [
            .iOS(.v14),
            .macOS(.v13)
        ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Legible",
            targets: ["Legible"]),
    ],
    dependencies: [
            .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "12.0.0")),
            .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "7.0.0"))
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Legible",
            dependencies: ["Nimble", "Quick"]),
        .testTarget(
            name: "LegibleTests",
            dependencies: ["Legible"]),
    ]
)
