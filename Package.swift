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
            path: "./Snowplow",
            publicHeadersPath: "./include",
            cSettings: [
                .headerSearchPath("./Internal/RemoteConfiguration"),
                .headerSearchPath("./Internal/Configurations"),
                .headerSearchPath("./Internal/Subject"),
                .headerSearchPath("./Internal/GDPR"),
                .headerSearchPath("./Internal/ScreenViewTracking"),
                .headerSearchPath("./Internal/Session"),
                .headerSearchPath("./Internal/Utils"),
                .headerSearchPath("./Internal/Storage"),
                .headerSearchPath("./Internal/NetworkConnection"),
                .headerSearchPath("./Internal/Tracker"),
                .headerSearchPath("./Internal/Payload"),
                .headerSearchPath("./Internal/Logger"),
                .headerSearchPath("./Internal/GlobalContexts"),
                .headerSearchPath("./Internal/Emitter"),
                .headerSearchPath("./Internal/Events"),
                .headerSearchPath("./Internal"),
            ]),
        .testTarget(
            name: "Snowplow-iOSTests",
            dependencies: ["SnowplowTracker"],
            path: "Snowplow iOSTests")
    ]
)
