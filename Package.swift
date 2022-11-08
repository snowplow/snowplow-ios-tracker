// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SnowplowTracker",
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
            path: "./Sources",
            publicHeadersPath: "./Snowplow/include",
            cSettings: [
                .headerSearchPath("./Core/RemoteConfiguration"),
                .headerSearchPath("./Core/Configurations"),
                .headerSearchPath("./Core/Subject"),
                .headerSearchPath("./Core/GDPR"),
                .headerSearchPath("./Core/ScreenViewTracking"),
                .headerSearchPath("./Core/Session"),
                .headerSearchPath("./Core/Utils"),
                .headerSearchPath("./Core/Storage"),
                .headerSearchPath("./Core/NetworkConnection"),
                .headerSearchPath("./Core/Tracker"),
                .headerSearchPath("./Core/Payload"),
                .headerSearchPath("./Core/Logger"),
                .headerSearchPath("./Core/GlobalContexts"),
                .headerSearchPath("./Core/Emitter"),
                .headerSearchPath("./Core/Events"),
                .headerSearchPath("./Core/Entities"),
                .headerSearchPath("./Core"),
            ]),
        .testTarget(
            name: "Tests",
            dependencies: ["SnowplowTracker"],
            path: "Tests")
    ]
)
