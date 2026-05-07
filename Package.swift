// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "ThunderRequest",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ThunderRequest",
            targets: ["ThunderRequest"]
        )
    ],
    targets: [
        .target(
            name: "ThunderRequest",
            path: "Sources/ThunderRequest"
        ),
        .testTarget(
            name: "ThunderRequestTests",
            dependencies: ["ThunderRequest"],
            path: "Tests/ThunderRequestTests",
            resources: [
                .copy("350x150.png")
            ]
        )
    ]
)
