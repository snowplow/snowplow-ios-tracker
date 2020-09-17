// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SnowplowTracker",
    platforms: [
        .iOS(.v9)
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
            path: "Snowplow",
            publicHeadersPath: "."),
        .testTarget(
            name: "Snowplow-iOSTests",
            dependencies: ["SnowplowTracker"],
            path: "Snowplow iOSTests")
    ]
)
