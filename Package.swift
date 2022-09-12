// swift-tools-version: 5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AvantisSwapSDK",
    platforms: [
        .iOS(SupportedPlatform.IOSVersion.v13),
        .macOS(SupportedPlatform.MacOSVersion.v11)
    ],
    products: [
        .library(
            name: "AvantisSwapSDK",
            targets: ["AvantisSwapSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/argentlabs/web3.swift",
                 from: "1.1.0"),
        .package(url: "https://github.com/Quick/Quick.git",
                 from: "5.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git",
                 from: "10.0.0"),
    ],
    targets: [
        .target(
            name: "AvantisSwapSDK",
            dependencies: ["web3.swift"]),
        .testTarget(
            name: "AvantisSwapSDKTests",
            dependencies: ["AvantisSwapSDK",
                           "Quick",
                           "Nimble"]),
    ]
)
