// swift-tools-version:5.3

import PackageDescription

let package = Package(name: "AvantisSwapSDK",
                      platforms: [
                        .iOS(SupportedPlatform.IOSVersion.v13),
                        .macOS(SupportedPlatform.MacOSVersion.v11)
                      ],
                      products: [
                          .library(
                              name: "AvantisSwapSDK",
                              targets: ["AvantisSwapSDK"]),
                      ],,
                      dependencies: [
                          .package(url: "https://github.com/argentlabs/web3.swift",
                                   from: "1.1.0"),
                          .package(url: "https://github.com/Quick/Quick.git",
                                   from: "5.0.0"),
                          .package(url: "https://github.com/Quick/Nimble.git",
                                   from: "10.0.0"),
                      ],
                      targets: [.target(name: "Alamofire",
                                        path: "Sources/AvantisSwapSDK"),
                                .testTarget(name: "AlamofireTests",
                                            dependencies: ["AvantisSwapSDK", "Quick", "Nimble"],
                                            path: "Tests/AvantisSwapSDKTests")],
                      swiftLanguageVersions: [.v5])
