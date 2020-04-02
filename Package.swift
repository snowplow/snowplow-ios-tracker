// swift-tools-version:5.2

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
        .package(name: "FMDB", url: "https://github.com/ccgus/fmdb", .revision("d68317fc0d7a986872ebf389f8d09b870fc88a7d"))
    ],
    targets: [
        .target(
            name: "SnowplowTracker",
            dependencies: ["FMDB", "Reachability"],
            path: "Snowplow",
            publicHeadersPath: "Snowplow")
    ]
)
