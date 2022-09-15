// swift-tools-version: 5.5
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
        .package(url: "https://github.com/attaswift/BigInt",
                 "5.0.0"..<"5.0.1"),
        .package(url: "https://github.com/Quick/Quick.git",
                 from: "5.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git",
                 from: "10.0.0"),
    ],
    targets: [
        .target(
            name: "keccaktiny",
            dependencies: [],
            path: "Libraries/keccak-tiny",
            exclude: ["module.map"]
        ),
        .target(
            name: "AvantisSwapSDK",
            dependencies: [.target(name: "keccaktiny"),
                           "BigInt"],
            path: "Sources/AvantisSwapSDK"
        ),
        .testTarget(
            name: "AvantisSwapSDKTests",
            dependencies: ["AvantisSwapSDK",
                           "Quick",
                           "Nimble"],
            path: "Tests/AvantisSwapSDKTests"
        ),
    ]
)
