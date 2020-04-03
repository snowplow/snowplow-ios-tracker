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
        .package(name: "FMDB", url: "https://github.com/ccgus/fmdb", .revision("dcd5bb68b348b51af7c76a51aa9f86f676feb3fc"))
    ],
    targets: [
        .target(
            name: "SnowplowTracker",
            dependencies: ["FMDB"],
            publicHeadersPath: "Snowplow")
    ]
)
