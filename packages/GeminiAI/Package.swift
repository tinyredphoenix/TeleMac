// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "GeminiAI",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "GeminiAI",
            targets: ["GeminiAI"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GeminiAI",
            dependencies: []),
    ]
)
