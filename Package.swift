// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SnowplowTracker",
    platforms: [
        .macOS("10.13"),
        .iOS("11.0"),
        .tvOS("11.0"),
        .watchOS("4.0")
    ],
    products: [
        .library(
            name: "SnowplowTracker",
            targets: ["SnowplowTracker"]),
    ],
    dependencies: [
        .package(name: "FMDB", url: "https://github.com/ccgus/fmdb", from: "2.7.6")
    ],
    targets: [
        .target(
            name: "SnowplowTracker",
            dependencies: ["FMDB"],
            path: "./Sources"),
        .testTarget(
            name: "Tests",
            dependencies: ["SnowplowTracker"],
            path: "Tests")
    ]
)
