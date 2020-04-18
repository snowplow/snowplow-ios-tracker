// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SnowplowTracker",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(
            name: "SnowplowTracker",
            targets: ["SnowplowTracker"]),
    ],
    dependencies: [
        .package(name: "FMDB", url: "https://github.com/ccgus/fmdb", .revision("d68317fc0d7a986872ebf389f8d09b870fc88a7d"))
    ],
    targets: [
        .target(
            name: "SnowplowTracker",
            dependencies: ["FMDB"],
            sources: ["Snowplow/", "Snowplow/Events/", "Snowplow/GlobalContext/"],
            publicHeadersPath: "."),
        .target(
            name: "Snowplow-iOSTests",
            dependencies: ["SnowplowTracker"],
            path: "Snowplow iOSTests")
    ]
)
