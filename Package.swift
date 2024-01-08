// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SnowplowTracker",
    defaultLocalization: "en",
    platforms: [
        .macOS("10.13"),
        .iOS("11.0"),
        .tvOS("12.0"),
        .watchOS("6.0")
    ],
    products: [
        .library(
            name: "SnowplowTracker",
            targets: ["SnowplowTracker"]),
    ],
    dependencies: [
        .package(name: "Mocker", url: "https://github.com/WeTransfer/Mocker.git", from: "2.5.4"),
    ],
    targets: [
        .target(
            name: "SnowplowTracker",
            path: "./Sources"),
        .testTarget(
            name: "Tests",
            dependencies: [
                "SnowplowTracker",
                "Mocker"
            ],
            path: "Tests"),
        .testTarget(
            name: "IntegrationTests",
            dependencies: [
                "SnowplowTracker"
            ],
            path: "IntegrationTests")
    ]
)
#if swift(>=5.6)
package.dependencies += [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
]
#endif
