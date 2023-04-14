// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSAppBuildPipelineActionsLib",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "iOSAppBuildPipelineActionsLib",
            targets: ["iOSAppBuildPipelineActionsLib"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.1.2"),
        .package(url: "https://github.com/tuist/XcodeProj.git", exact: "8.7.1"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", exact: "0.9.14"),
        .package(url: "https://github.com/krzysztofzablocki/Difference.git", exact: "1.0.1")
    ],
    targets: [
        .target(
            name: "iOSAppBuildPipelineActionsLib",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "XcodeProj", package: "XcodeProj"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ]
        ),
        .testTarget(
            name: "iOSAppBuildPipelineActionsLibTests",
            dependencies: [
                .product(name: "Difference", package: "Difference"),
                "iOSAppBuildPipelineActionsLib"
            ],
            resources: [
                .copy("Stubs")
            ]
        )
    ]
)
