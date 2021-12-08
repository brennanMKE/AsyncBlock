// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncBlock",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_14),
        .tvOS(.v12),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "AsyncBlock",
            targets: ["AsyncBlock"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AsyncBlock",
            dependencies: []),
        .testTarget(
            name: "AsyncBlockTests",
            dependencies: ["AsyncBlock"]),
    ]
)
