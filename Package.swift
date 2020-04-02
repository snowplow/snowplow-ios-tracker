// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SnowplowTracker",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(
            name: "SnowplowTracker",
            targets: ["SnowplowTracker"]),
    ],
    dependencies: [
        .package(name: "Reachability", url: "https://github.com/ashleymills/Reachability.swift", from: "4.3.1"),
        .package(name: "FMDB", url: "https://github.com/ccgus/fmdb", .revision("9b100cc3dd83ff88a17a4da8718eab4b08e2fe67"))
    ],
    targets: [
        .target(
            name: "SnowplowTracker",
            dependencies: ["FMDB", "Reachability"],
            path: "Snowplow",
            publicHeadersPath: "Snowplow")
    ]
)
